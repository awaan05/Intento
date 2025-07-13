//
//  PomodoroModel.swift
//  doro doro
//
//  Created by Mohammad Awaan Nisar on 29/06/25.
//

import SwiftUI
import Foundation

enum TimerState {
    case ready
    case running
    case paused
    case breakReady
    case breakRunning
}

enum SessionType {
    case work
    case shortBreak
    case longBreak
}
