import Foundation

@MainActor
final class SessionTimerService {
    private var timer: Timer?

    func start(onTick: @escaping () -> Void) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            onTick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
