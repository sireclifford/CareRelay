import Foundation

@Observable
final class Session {
    static let idleTimeout: TimeInterval = 5 * 60
    var currentStaff: Staff?
    
    private var lastActivity = Date()
    private var idleCheckTimer: Timer?
    
    init() {
        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.checkIdle()
        }
    }
    
    deinit {
        idleCheckTimer?.invalidate()
    }
    func recordActivity() {
        lastActivity = Date()
    }
    
    private func checkIdle() {
        guard currentStaff != nil else {return}
        if Date().timeIntervalSince(lastActivity) > Self.idleTimeout {
            currentStaff = nil
        }
    }
}
