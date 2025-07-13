//
//  PomodoroViewModel.swift
//  doro doro
//
//  Created by Mohammad Awaan Nisar on 29/06/25.
//

import SwiftUI
import Foundation

class PomodoroViewModel: ObservableObject {
    @Published var timeRemaining: Int = 25
    @Published var isRunning: Bool = false
    @Published var timerState: TimerState = .ready
    @Published var currentSession: Int = 1
    @Published var sessionType: SessionType = .work
    
    private var timer: Timer?
    let workDuration = 25
    let shortBreakDuration = 5
    let longBreakDuration = 15
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
    
//    private func handleTimerCompletion() {
//        stopTimer()
//        isRunning = false
//        
//        switch sessionType {
//        case .work:
//            // Work session completed, prepare for break
//            if currentSession == totalSessions {
//                // Last session - long break
//                sessionType = .longBreak
//                timeRemaining = longBreakDuration
//            } else {
//                // Regular break
//                sessionType = .shortBreak
//                timeRemaining = shortBreakDuration
//            }
//            timerState = .breakReady
//            
//        case .shortBreak, .longBreak:
//            // Break completed
//            if sessionType == .longBreak {
//                // Long break completed - reset to session 1
//                currentSession = 1
//            } else {
//                // Short break completed - next session
//                currentSession += 1
//            }
//            
//            // Prepare for next work session
//            sessionType = .work
//            timeRemaining = workDuration
//            timerState = .ready
//        }
//    }
    
    private func handleTimerCompletion() {
        stopTimer()

        switch sessionType {
        case .work:
            if currentSession == totalSessions {
                // Last session - long break
                sessionType = .longBreak
                timeRemaining = longBreakDuration
            } else {
                // Regular short break
                sessionType = .shortBreak
                timeRemaining = shortBreakDuration
            }
            timerState = .breakRunning
            startCountdown()  // ⬅️ Automatically start break

        case .shortBreak:
            currentSession += 1
            sessionType = .work
            timeRemaining = workDuration
            timerState = .running
            startCountdown()  // ⬅️ Automatically start next work session

        case .longBreak:
            currentSession = 1
            sessionType = .work
            timeRemaining = workDuration
            timerState = .ready
            // Stop here and let user manually restart if they want
        }
    }
    
}
