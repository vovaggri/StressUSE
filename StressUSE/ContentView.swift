//
//  ContentView.swift
//  StessUSE
//
//  Created by Vladimir Grigoryev on 05.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var appViewModel = AppViewModel()

    var body: some View {
        ZStack {
            TabView(selection: $appViewModel.selectedTab) {
                NavigationStack {
                    if let selectedDeck = appViewModel.selectedDeck {
                        DeckDetailView(
                            viewModel: DeckDetailViewModel(
                                deck: selectedDeck,
                                weakTopicStats: appViewModel.weakTopicStats,
                                recentResults: appViewModel.history.filter { $0.deckID == selectedDeck.id }
                            ),
                            premiumAccess: appViewModel.premiumAccess,
                            onStartStressMode: { durationMinutes in
                                appViewModel.startStressMode(for: selectedDeck, durationMinutes: durationMinutes)
                            },
                            onBack: appViewModel.closeDeckDetail
                        )
                    } else {
                        HomeView(
                            decks: appViewModel.decks,
                            history: appViewModel.history,
                            weakTopicStats: appViewModel.weakTopicStats,
                            premiumAccess: appViewModel.premiumAccess,
                            onSelectDeck: appViewModel.selectDeck,
                            onCreateDeck: appViewModel.presentDeckComposer,
                            onDeleteDeck: appViewModel.deleteCustomDeck,
                            onOpenPremium: { appViewModel.presentPremiumOffer(for: .stressMode) }
                        )
                    }
                }
                .tabItem {
                    Label("Наборы", systemImage: "rectangle.stack.fill")
                }
                .tag(AppTab.decks)

                NavigationStack {
                    if appViewModel.premiumAccess.hasPremiumAccess {
                        MistakesView(
                            mistakesDeck: appViewModel.latestMistakesDeck,
                            weakTopics: appViewModel.topWeakTopics,
                            onStart: appViewModel.startMistakeRecovery
                        )
                    } else {
                        PremiumLockedView(
                            feature: .analytics,
                            premiumAccess: appViewModel.premiumAccess,
                            onOpenPremium: { appViewModel.presentPremiumOffer(for: .analytics) }
                        )
                    }
                }
                .tabItem {
                    Label("Ошибки", systemImage: "arrow.trianglehead.clockwise")
                }
                .tag(AppTab.mistakes)

                NavigationStack {
                    if appViewModel.premiumAccess.hasPremiumAccess {
                        StatisticsView(
                            totalSessions: appViewModel.totalSessionsCount,
                            totalTrainingSeconds: appViewModel.totalTrainingSeconds,
                            averageScorePercent: appViewModel.averageScorePercent,
                            strongestSubject: appViewModel.strongestSubject,
                            recentHistory: appViewModel.history,
                            weakTopics: appViewModel.topWeakTopics
                        )
                    } else {
                        PremiumLockedView(
                            feature: .analytics,
                            premiumAccess: appViewModel.premiumAccess,
                            onOpenPremium: { appViewModel.presentPremiumOffer(for: .analytics) }
                        )
                    }
                }
                .tabItem {
                    Label("Статистика", systemImage: "chart.pie.fill")
                }
                .tag(AppTab.statistics)

                NavigationStack {
                    SettingsView(
                        premiumAccess: appViewModel.premiumAccess,
                        onOpenPremium: { appViewModel.presentPremiumOffer(for: .stressMode) },
                        onRestorePurchases: { Task { await appViewModel.restorePremiumPurchases() } }
                    )
                }
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
            }
            .tint(Color(hex: "#2563EB"))

            if let result = appViewModel.latestResult,
               let deck = appViewModel.resultDeck {
                ResultsView(
                    record: result,
                    deck: deck,
                    weakTopicStats: appViewModel.weakTopicStats,
                    mistakesDeck: appViewModel.latestMistakesDeck,
                    onRetry: appViewModel.retryLastDeck,
                    onOpenMistakesTab: appViewModel.openMistakesTab,
                    onBackToLibrary: appViewModel.returnToLibrary
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }

            if let sessionViewModel = appViewModel.activeSessionViewModel {
                StressSessionView(
                    viewModel: sessionViewModel,
                    onExit: appViewModel.handleSessionExit
                )
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.92), value: appViewModel.navigationState)
        .sheet(
            isPresented: Binding(
                get: { appViewModel.isPresentingDeckComposer },
                set: { isPresented in
                    appViewModel.isPresentingDeckComposer = isPresented
                }
            )
        ) {
            NavigationStack {
                CreateDeckView(
                    viewModel: appViewModel.deckComposerViewModel,
                    onClose: appViewModel.dismissDeckComposer,
                    onSave: appViewModel.saveCustomDeck
                )
            }
            .presentationDetents([.large])
        }
        .sheet(
            isPresented: Binding(
                get: { appViewModel.isPresentingPremiumOffer },
                set: { isPresented in
                    appViewModel.isPresentingPremiumOffer = isPresented
                }
            )
        ) {
            PremiumOfferView(
                premiumAccess: appViewModel.premiumAccess,
                feature: appViewModel.requestedPremiumFeature,
                onClose: appViewModel.dismissPremiumOffer,
                onPurchase: { Task { await appViewModel.purchasePremium() } },
                onRestore: { Task { await appViewModel.restorePremiumPurchases() } }
            )
            .presentationDetents([.large])
        }
    }
}

#Preview {
    ContentView()
}
