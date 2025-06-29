//
//  ContentView.swift
//  doro doro
//
//  Created by Mohammad Awaan Nisar on 28/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 10) {
                Text("Pomodoro Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Session \(viewModel.currentSession) of 4")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(viewModel.sessionType == .work ? "Work Time" :
                     viewModel.sessionType == .shortBreak ? "Short Break" : "Long Break")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Timer Display
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        viewModel.sessionType == .work ? Color.red : Color.green,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: progressValue)
                
                Text(viewModel.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(viewModel.sessionType == .work ? .red : .green)
            }
            
            // Control Buttons
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    // Main Action Button
                    Button(action: mainButtonAction) {
                        Text(mainButtonTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(mainButtonColor)
                            .cornerRadius(25)
                    }
                    .disabled(!isMainButtonEnabled)
                    
                    // Reset Button (only for work sessions)
                    if viewModel.canShowResetButton {
                        Button(action: {
                            viewModel.resetTimerForCurrentSession()
                        }) {
                            Text("Reset")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    private var progressValue: Double {
        let totalTime: Double
        switch viewModel.sessionType {
        case .work:
            totalTime = 10
            ///1500
        case .shortBreak:
            totalTime = 5
            /// 300
        case .longBreak:
            totalTime = 7
            /// 1200
        }
        return 1.0 - (Double(viewModel.timeRemaining) / totalTime)
    }
    
    private var mainButtonTitle: String {
        switch viewModel.timerState {
        case .ready:
            return "Start"
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .breakReady:
            return "Break"
        case .breakRunning:
            return "Break"
        }
    }
    
    private var mainButtonColor: Color {
        switch viewModel.timerState {
        case .ready:
            return .green
        case .running:
            return .orange
        case .paused:
            return .blue
        case .breakReady:
            return .green
        case .breakRunning:
            return .gray
        }
    }
    
    private var isMainButtonEnabled: Bool {
        return viewModel.timerState != .breakRunning
    }
    
    private func mainButtonAction() {
        switch viewModel.timerState {
        case .ready:
            viewModel.startTimer()
        case .running:
            viewModel.pauseTimer()
        case .paused:
            viewModel.resumeTimer()
        case .breakReady:
            viewModel.startBreak()
        case .breakRunning:
            break // Button is disabled, no action
        }
    }
}


// MARK: - Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

#Preview {
    ContentView()
}
