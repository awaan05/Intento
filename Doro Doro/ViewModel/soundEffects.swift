//
//  soundEffects.swift
//  doro doro
//
//  Created by Mohammad Awaan Nisar on 12/07/25.
//

import Foundation
import AVKit

class SoundEffects: ObservableObject {
    
    var player: AVAudioPlayer?
    
    enum soundOption: String {
        case start
        case sbreak1
        case sbreak2
        case lbreak
    }
    
    func playSound(sound: soundOption) {
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
}
