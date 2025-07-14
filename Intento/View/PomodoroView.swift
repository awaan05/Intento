//
//  PomodoroView.swift
//  Intento
//
//  Created by Mohammad Awaan Nisar on 29/06/25.
//

import SwiftUI

struct PomodoroView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    @State private var animationTrigger: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @StateObject var sound = SoundEffects()
    @StateObject var haptic = HapticFeedback()
    
    var body: some View {
            VStack(spacing: 100) {
                VStack(spacing: 40) {
                    HStack(alignment: .bottom, spacing: 57) {
                        
                        // Session 1 Capsule
                        ZStack(){
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 18, height: 80)
                            Capsule()
                                .fill(Color(red: 152/255, green: 251/255, blue: 152/255))
                                .mask(Rectangle()
                                    .frame(height: 80 * getSessionProgress(for: 1))
                                    .offset(y: 40 - (80 * getSessionProgress(for: 1)) / 2))
                                .frame(width: 18, height: 80)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: getSessionProgress(for: 1))
                                
                        }
                        
                        // Session 2 Capsule
                        ZStack(){
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 18, height: 110)
                            Capsule()
                                .fill(Color(red: 144/255, green: 238/255, blue: 144/255))
                                .mask(Rectangle()
                                    .frame(height: 110 * getSessionProgress(for: 2))
                                    .offset(y: 55 - (110 * getSessionProgress(for: 2)) / 2))
                                .frame(width: 18, height: 110)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: getSessionProgress(for: 2))
                        }
                        
                        // Session 3 Capsule
                        ZStack(){
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 18, height: 150)
                            Capsule()
                                .fill(Color(red: 50/255, green: 205/255, blue: 50/255))
                                .mask(Rectangle()
                                    .frame(height: 150 * getSessionProgress(for: 3))
                                    .offset(y: 75 - (150 * getSessionProgress(for: 3)) / 2))
                                .frame(width: 18, height: 150)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: getSessionProgress(for: 3))
                        }
                        
                        // Session 4 Capsule
                        ZStack(){
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 18, height: 220)
                            Capsule()
                                .fill(Color(red: 34/255, green: 139/255, blue: 34/255))
                                .mask(Rectangle()
                                    .frame(height: 220 * getSessionProgress(for: 4))
                                    .offset(y: 110 - (220 * getSessionProgress(for: 4)) / 2))
                                .frame(width: 18, height: 220)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5), value: getSessionProgress(for: 4))
                        }
                    }
                    
                    // Timer
                    Text(viewModel.formattedTime)
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(Color(UIColor.label))
                }
                
                // Main Button
                Button(action: {
                    triggerButtonAnimation()
                    mainButtonAction()
                }) {
                    ZStack {
                        
                        // Button Capsule
                        Capsule()
                            .fill(viewModel.timerState == .breakRunning ? Color(breakBarColor) : mainButtonColor)
                            .frame(
                                width: viewModel.timerState == .breakRunning ? 250 : (isCompactButton ? 100 : 180),
                                height: viewModel.timerState == .breakRunning ? 150 : (isCompactButton ? 55 : 70)
                            )
                            .animation(.spring(response: 0.5, dampingFraction: 0.45), value: viewModel.timerState)
                        
                        ZStack {
                            
                            // Primary button text
                            Text(primaryButtonText)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .light ? .white : .black)
                                .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(viewModel.timerState == .ready ? 0.3 : 0), value: viewModel.timerState)
                            
                            // Secondary button text
                            Text(secondaryButtonText)
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .scaleEffect(showSecondaryText && viewModel.timerState != .breakRunning ? 0.7 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showSecondaryText)
                                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: viewModel.timerState)
                        }
                    }
                }
                .buttonStyle(NoFlashButtonStyle())
                .disabled(!isMainButtonEnabled)
                .frame(height: 200)
            }
            .onChange(of: viewModel.timerState) { oldState, newState in
                // Only animate automatic state changes
                if oldState != newState {
                    triggerButtonAnimation()
                }
                
                // Play sound when transitioning to break states
                        if newState == .breakRunning {
                            if viewModel.sessionType == .shortBreak || viewModel.sessionType == .longBreak {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    sound.playSound(sound: .sbreak1)
                                }
                            }
                        }
                
                        // Play sound when work session starts automatically (after break)
                        else if newState == .running && oldState == .breakRunning {
                            sound.playSound(sound: .start)
                        }
                
                        // Play sound when long break ends and goes to ready state
                       else if newState == .ready && oldState == .breakRunning && viewModel.sessionType == .work {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                               sound.playSound(sound: .lbreak)
                           }
                       }
                }
        
        }
        
    
    // MARK: - Computed Properties
    
    private func getSessionProgress(for sessionNumber: Int) -> Double {
        if viewModel.currentSession > sessionNumber {
            // Completed session - always fully filled
            return 1.0
        } else if viewModel.currentSession == sessionNumber {
            // Current session
            if viewModel.sessionType == .work {
                
                let totalTime: Double = Double(viewModel.workDuration)
                return 1.0 - (Double(viewModel.timeRemaining) / totalTime)
                
                
            } else {
                // During break after completing this session - keep it filled
                return 1.0
            }
        } else {
            // Future session - empty
            return 0.0
        }
    }
    
    // Break progress
    private var breakProgress: Double {
        
        let totalTime: Double
        switch viewModel.sessionType {
        case .shortBreak:
            totalTime = Double(viewModel.shortBreakDuration)
        case .longBreak:
            totalTime = Double(viewModel.longBreakDuration)
        default:
            totalTime = 1
        }
        
        return Double(viewModel.timeRemaining) / totalTime
    }
    
    // Break capsule color
    private var breakBarColor: Color {
        switch viewModel.sessionType {
        case .shortBreak:
            return Color(UIColor.systemOrange)
        case .longBreak:
            return Color(UIColor.label)
        default:
            return Color(UIColor.systemGray4)
        }
    }
    
    private var isCompactButton: Bool {
        return viewModel.timerState == .running
    }
    
    private var showPrimaryText: Bool {
        return viewModel.timerState == .ready || viewModel.timerState == .breakReady || viewModel.timerState == .paused
    }
    
    private var showSecondaryText: Bool {
        return viewModel.timerState == .running
    }
    
    private var primaryButtonText: String {
        switch viewModel.timerState {
        case .ready:
            return "Focus"
        default:
            return ""
        }
    }
    
    private var secondaryButtonText: String {
        switch viewModel.timerState {
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .breakRunning:
            return viewModel.sessionType == .shortBreak ? "Quick Break" : "Recover"
        default:
            return ""
        }
    }
    
    private var mainButtonColor: Color {
        switch viewModel.timerState {
        case .ready:
            return Color(UIColor.label)
        case .running:
            return Color(UIColor.systemRed)
        case .paused:
            return Color(UIColor.systemTeal)
        case .breakReady:
            if viewModel.sessionType == .longBreak {
                return Color.black
            } else {
                return Color(UIColor.systemOrange)
            }
        default:
            return Color.gray
        }
    }
    
    private var isMainButtonEnabled: Bool {
        return viewModel.timerState != .breakRunning
    }
    
    private func triggerButtonAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            animationTrigger.toggle()
        }
    }
    
    private func mainButtonAction() {
        switch viewModel.timerState {
        case .ready:
            viewModel.startTimer()
            sound.playSound(sound: .start)
            haptic.impact(style: .soft)
        case .running:
            viewModel.pauseTimer()
            haptic.impact(style: .medium)
        case .paused:
            viewModel.resumeTimer()
            haptic.impact(style: .soft)
        case .breakReady:
            viewModel.startBreak()
        case .breakRunning:
            break
        }
    }
    
    
}

// MARK: - Custom Button Style (to avoid flash when clicked)
struct NoFlashButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    PomodoroView()
}
