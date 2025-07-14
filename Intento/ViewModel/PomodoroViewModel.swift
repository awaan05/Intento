//
//  PomodoroViewModel.swift
//  Intento
//
//  Created by Mohammad Awaan Nisar on 29/06/25.
//

import SwiftUI
import Foundation

class PomodoroViewModel: ObservableObject {
    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var timerState: TimerState = .ready
    @Published var currentSession: Int = 1
    @Published var sessionType: SessionType = .work
    
    private var timer: Timer?
    let workDuration = 25 * 60
    let shortBreakDuration = 5 * 60
    let longBreakDuration = 15 * 60
    private let totalSessions = 4
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var canShowResetButton: Bool {
        return (timerState == .running || timerState == .paused) && sessionType == .work
    }
    
    func startTimer() {
        timerState = .running
        isRunning = true
        startCountdown()
    }
    
    func pauseTimer() {
        timerState = .paused
        isRunning = false
        stopTimer()
    }
    
    func resumeTimer() {
        timerState = .running
        isRunning = true
        startCountdown()
    }
    
    func resetTimerForCurrentSession() {
        stopTimer()
        isRunning = false
        if sessionType == .work {
            timeRemaining = workDuration
            timerState = .ready
        }
    }
    
    func startBreak() {
        timerState = .breakRunning
        isRunning = true
        startCountdown()
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.handleTimerCompletion()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimerCompletion() {
        stopTimer()

        switch sessionType {
        case .work:
            if currentSession == totalSessions {
                sessionType = .longBreak
                timeRemaining = longBreakDuration
            } else {
                sessionType = .shortBreak
                timeRemaining = shortBreakDuration
            }
            timerState = .breakRunning
            
            // Automatically start break
            startCountdown()

        case .shortBreak:
            currentSession += 1
            sessionType = .work
            timeRemaining = workDuration
            timerState = .running
            
            // Automatically start next work session
            startCountdown()

        case .longBreak:
            currentSession = 1
            sessionType = .work
            timeRemaining = workDuration
            timerState = .ready
            // End of complete a complete session. Stop here and let user manually restart if they want
        }
    }
    
}
