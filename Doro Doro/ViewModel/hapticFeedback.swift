//
//  hapticFeedback.swift
//  Doro Doro
//
//  Created by Mohammad Awaan Nisar on 12/07/25.
//

import Foundation
import UIKit

class HapticFeedback: ObservableObject {
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
