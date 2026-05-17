import Foundation
import Observation
import StoreKit
#if DEBUG
#if canImport(StoreKitTest)
import StoreKitTest
#endif
#endif

enum PremiumFeature: String, Identifiable {
    case stressMode
    case analytics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stressMode:
            "Stress Mode"
        case .analytics:
            "Персональная аналитика"
        }
    }

    var subtitle: String {
        switch self {
        case .stressMode:
            "Экзаменационная сессия на определенное время с отвлекающими звуками, таймером и фиксацией пропущенных вопросов."
        case .analytics:
            "Слабые темы, история попыток и автоматическая работа над ошибками."
        }
    }
}

private enum PremiumAccessError: Error {
    case failedVerification
}

@Observable
@MainActor
final class PremiumAccessService {
    nonisolated static let premiumMonthlyProductID = "stressuse.premium.monthly"

    private let productIDs: Set<String>
    private let debugPremiumOverrideKey = "stressuse.premium.debugOverride"
    private var transactionUpdatesTask: Task<Void, Never>?
    #if DEBUG
    #if canImport(StoreKitTest)
    private var localTestSession: SKTestSession?
    #endif
    #endif

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoadingProducts = false
    private(set) var isPurchasing = false
    private(set) var purchaseErrorMessage: String?
    private(set) var isLocalStoreKitFileBundled = false
    private(set) var isDebugPremiumOverrideEnabled = UserDefaults.standard.bool(forKey: "stressuse.premium.debugOverride")

    init(productIDs: Set<String> = [PremiumAccessService.premiumMonthlyProductID]) {
        self.productIDs = productIDs
        transactionUpdatesTask = listenForTransactionUpdates()
        Task {
            await refresh()
        }
    }

    var hasPremiumAccess: Bool {
        #if DEBUG
        if isDebugPremiumOverrideEnabled { return true }
        #endif
        return !purchasedProductIDs.isDisjoint(with: productIDs)
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.premiumMonthlyProductID }
    }

    var displayPrice: String {
        monthlyProduct?.displayPrice ?? "199 ₽"
    }

    var hasIntroductoryTrial: Bool {
        monthlyProduct?.subscription?.introductoryOffer != nil
    }

    var isStoreKitReady: Bool {
        monthlyProduct != nil
    }

    var statusTitle: String {
        if hasPremiumAccess {
            "Premium активен"
        } else if isLoadingProducts {
            "Загружаем подписку"
        } else if isStoreKitReady {
            "Покупайте Premium для расширенного функционала"
        } else {
            "Подписка недоступна"
        }
    }

    var statusSubtitle: String {
        if hasPremiumAccess {
            #if DEBUG
            if isDebugPremiumOverrideEnabled {
                return "Premium включён для проверки приложения."
            }
            #endif
            return "Stress Mode и персональная аналитика открыты."
        } else if isLoadingProducts {
            return "Загружаем предложение premium-доступа."
        } else if let purchaseErrorMessage {
            return purchaseErrorMessage
        } else if hasIntroductoryTrial {
            return "7 дней бесплатно, затем \(displayPrice) в месяц."
        } else if isStoreKitReady {
            return "\(displayPrice) в месяц."
        } else if isLocalStoreKitFileBundled {
            return "Не удалось загрузить предложение premium-доступа. Попробуй позже."
        } else {
            return "Не удалось подготовить premium-доступ. Попробуй переустановить приложение."
        }
    }

    var primaryActionTitle: String {
        if isPurchasing {
            "Открываем оплату..."
        } else if !isStoreKitReady {
            #if DEBUG
            "Включить premium для теста"
            #else
            "Подключить за \(displayPrice)/мес"
            #endif
        } else if hasIntroductoryTrial {
            "Начать 7 дней бесплатно"
        } else {
            "Подключить за \(displayPrice)/мес"
        }
    }

    func refresh() async {
        await loadProducts()
        await updateCustomerProductStatus()
    }

    func purchasePremium() async {
        purchaseErrorMessage = nil

        guard let monthlyProduct else {
            await loadProducts()
            guard let monthlyProduct else {
                #if DEBUG
                enableDebugPremiumOverride()
                purchaseErrorMessage = nil
                return
                #else
                purchaseErrorMessage = "Не удалось загрузить предложение premium-доступа."
                return
                #endif
            }
            await purchase(monthlyProduct)
            return
        }

        await purchase(monthlyProduct)
    }

    func restorePurchases() async {
        purchaseErrorMessage = nil
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            purchaseErrorMessage = "Не удалось восстановить покупки. Попробуй позже."
        }
    }

    func resetDebugPremiumOverride() {
        isDebugPremiumOverrideEnabled = false
        UserDefaults.standard.set(false, forKey: debugPremiumOverrideKey)
    }

    private func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            configureLocalStoreKitSessionIfNeeded()
            products = try await Product.products(for: productIDs).sorted { $0.displayName < $1.displayName }
            if products.isEmpty {
                purchaseErrorMessage = "Не удалось загрузить предложение premium-доступа."
            }
        } catch {
            purchaseErrorMessage = "Не удалось загрузить предложение premium-доступа."
        }
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateCustomerProductStatus()
            case .userCancelled:
                purchaseErrorMessage = nil
            case .pending:
                purchaseErrorMessage = "Покупка ожидает подтверждения."
            @unknown default:
                purchaseErrorMessage = "Не удалось завершить покупку. Попробуй ещё раз."
            }
        } catch {
            purchaseErrorMessage = "Покупка не завершена. Попробуй ещё раз."
        }
    }

    private func updateCustomerProductStatus() async {
        var activeProductIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                guard productIDs.contains(transaction.productID) else { continue }

                if transaction.revocationDate == nil {
                    activeProductIDs.insert(transaction.productID)
                }
            } catch {
                purchaseErrorMessage = "Не удалось подтвердить покупку."
            }
        }

        purchasedProductIDs = activeProductIDs
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                } catch {
                    await MainActor.run {
                        self.purchaseErrorMessage = "Не удалось обновить статус покупки."
                    }
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PremiumAccessError.failedVerification
        }
    }

    private func enableDebugPremiumOverride() {
        isDebugPremiumOverrideEnabled = true
        UserDefaults.standard.set(true, forKey: debugPremiumOverrideKey)
    }

    private func configureLocalStoreKitSessionIfNeeded() {
        #if DEBUG
        #if canImport(StoreKitTest)
        guard localTestSession == nil else { return }
        guard let storeKitURL = Bundle.main.url(forResource: "StressUSE", withExtension: "storekit") else {
            isLocalStoreKitFileBundled = false
            return
        }
        isLocalStoreKitFileBundled = true

        do {
            let session = try SKTestSession(contentsOf: storeKitURL)
            session.disableDialogs = false
            localTestSession = session
        } catch {
            purchaseErrorMessage = "Не удалось подготовить premium-доступ."
        }
        #endif
        #endif
    }
}
