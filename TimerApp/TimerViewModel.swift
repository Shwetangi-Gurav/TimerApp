//
//  TimerViewModel.swift
//  TimerApp
//
//  Created by Shwetangi Gurav on 05/01/24.
//

import Combine
import SwiftUI
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var formattedTimeText: String
    @Published private(set) var isRunning: Bool
    
    private var cancellables = Set<AnyCancellable>()
    private var backgroundTask: Task<Void, Never>?
    
    init(timeInterval: TimeInterval) {
        self.timeRemaining = timeInterval
        self.formattedTimeText = "00:00:00"
        self.isRunning = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func startPauseTimer() {
        isRunning.toggle()
        if isRunning {
            startTimer()
        } else {
            cancellables.removeAll()
        }
    }
    
    func stopTimer() {
        self.timeRemaining = 60
        self.formattedTimeText = "00:00:00"
        if isRunning {
            isRunning.toggle()
        }
        cancellables.removeAll()
    }
    
    // MARK: Notification methods
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToBackground() {
        backgroundTask = Task {
            await Task.sleep(2)
            self.startTimer()
        }
    }
    
    @objc func appCameToForeground() {
        backgroundTask?.cancel()
    }
    
    
    // MARK: Private methods
    private func startTimer() {
        Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.01
                    self.formattedTimeText = self.formatMmSsMl(counter: self.timeRemaining)
                } else {
                    self.stopTimer()
                    self.triggerNotification()
                }
            }
            .store(in: &cancellables)
    }
    
    private func formatMmSsMl(counter: Double) -> String {
        let minutes = Int((counter/60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(counter.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((counter*1000).truncatingRemainder(dividingBy: 1000))
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    private func triggerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended !!"
        content.body = "Your timer has reached zero."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
