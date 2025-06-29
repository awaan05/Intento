////
////  PomodoroViewModel.swift
////  doro doro
////
////  Created by Mohammad Awaan Nisar on 29/06/25.
////
//
import SwiftUI

class PomodoroViewModel: ObservableObject {
    @Published var timeRemaining: Int = 10
    @Published var isRunning: Bool = false
    @Published var timerState: TimerState = .ready
    @Published var currentSession: Int = 1
    @Published var sessionType: SessionType = .work
    
    private var timer: Timer?
    private let workDuration = 10
    private let shortBreakDuration = 5
    private let longBreakDuration = 8
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
        startCountdown()
    }
    
    func pauseTimer() {
        timerState = .paused
        stopTimer()
    }
    
    func resumeTimer() {
        timerState = .running
        startCountdown()
    }
    
    func resetTimerForCurrentSession() {
        stopTimer()
        if sessionType == .work {
            timeRemaining = workDuration
            timerState = .ready
        }
    }
    
    func startBreak() {
        timerState = .breakRunning
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
            // Work session completed, prepare for break
            if currentSession == totalSessions {
                // Last session - long break
                sessionType = .longBreak
                timeRemaining = longBreakDuration
            } else {
                // Regular break
                sessionType = .shortBreak
                timeRemaining = shortBreakDuration
            }
            timerState = .breakReady
            
        case .shortBreak, .longBreak:
            // Break completed
            if sessionType == .longBreak {
                // Long break completed - reset to session 1
                currentSession = 1
            } else {
                // Short break completed - next session
                currentSession += 1
            }
            
            // Prepare for next work session
            sessionType = .work
            timeRemaining = workDuration
            timerState = .ready
        }
    }
}
