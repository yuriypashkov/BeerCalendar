//
//  SoundService.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/6/21.
//

import Foundation
import AVFoundation

class SoundService {
    
    var sounds: [AVAudioPlayer] = []
    var soundNames = ["pageSound1", "pageSound2", "pageSound3", "pageSound4", "pageSound5"]
    var shortSound: AVAudioPlayer?
    
    init() {
        
        // выставляем категорию audiosession чтобы не прерывать фоновую музыку при воспроизведении звуков
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // инициализируем массив звуков для перелистывания страничек
        for name in soundNames {
            
            if let file = Bundle.main.path(forResource: name, ofType: "mp3") {
                do {
                    //print("Create audio player instance")
                    
                    let sound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file))
                    
                    sound.volume = 0.5
                    sound.prepareToPlay()
                    
                    sounds.append(sound)
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
        // инициализируем короткий звук для быстрого перелистывания
        if let shortSoundFile = Bundle.main.path(forResource: "shortSound", ofType: "mp3") {
            do {
                shortSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: shortSoundFile))
                shortSound?.volume = 0.5
                shortSound?.prepareToPlay()
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
    
    func playRandomSound() {
        if let sound = sounds.randomElement() {
            sound.play()
        }
    }
    
    func playShortSound() {
        if let shortSound = shortSound {
            shortSound.play()
        }
    }
    
}
