//
//  AudioPlayer.swift
//  Chip8
//
//  Created by Wilbur on 2016/02/24.
//  Copyright © 2016 Retroforce. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    private var player:AVAudioPlayer!
    
    static func defaultPlayer(soundFile file:String) -> AudioPlayer {
        
        let a = AudioPlayer()
        
        let audioFile = NSBundle.mainBundle().pathForResource(file, ofType: "wav")
        
        do {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            a.player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioFile!))
            a.player.prepareToPlay()
            
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return a
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func pause() {
        player.pause()
    }

}
