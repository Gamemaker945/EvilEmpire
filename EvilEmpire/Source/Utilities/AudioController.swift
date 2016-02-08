//
//  AudioController.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/8/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import AVFoundation

// -----------------------------------------------------------------------------
// MARK: - Sound Type Enumeration

enum SoundType: Int {
    
    case Explosion = 0
    case GlassBreak
    case Alarm
    case Wind
    
    // File name for the audio file to be used
    var fileName: String {
        switch self {
            case .Explosion:
                return "Explosion"
            case .GlassBreak:
                return "glassBreak"
            case .Alarm:
                return "RedAlert"
            case .Wind:
                return "Wind"
        }
    }
    
    // File type for the audio file to be used. Currently all mp3, setup enum
    // to allow for other types
    var fileType: String {
        switch self {
            case .Explosion, .GlassBreak, .Alarm, .Wind:
                return "mp3"
        }
    }
    
    // Number of loops to be played for each effect
    var numLoops: Int {
        switch self {
            case .Explosion:
                return 0
            case .GlassBreak:
                return 0
            case .Alarm:
                return 4
            case .Wind:
                return -1
        }
    }
    
    static let allValues = [Explosion, GlassBreak, Alarm, Wind]
}

// -----------------------------------------------------------------------------
// MARK: - Audio Controller Class

class AudioController {
    
    // Audio dictionary for storing the players
    private var audio = [SoundType:AVAudioPlayer]()

    init () {
        self.setup()
    }
    
    // Initialize all of the sounds
    private func setup () {
        for sound in SoundType.allValues {

            let soundURL = NSURL(fileURLWithPath: NSBundle.mainBundle()
                    .pathForResource(sound.fileName, ofType: sound.fileType)!)
            
            
            do {
                let player = try AVAudioPlayer(contentsOfURL: soundURL, fileTypeHint: nil)
                
                player.numberOfLoops = sound.numLoops
                player.prepareToPlay()
                
                //4 add to the audio dictionary
                audio[sound] = player

            } catch _ {
                // Error here
            }
        }
    }
    
    /**
     Play the sound of the given type
     - parameter type: type of sound to be played
     
     */
    func playSound (type: SoundType) {
        
        if let player = audio[type] {
            if player.playing {
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }
}

