//
//  UUAVAudioPlayer.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/2.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc
protocol UUAVAudioPlayerDelegate {
    @objc optional func UUAVAudioPlayerBeiginLoadVoice()
    @objc optional func UUAVAudioPlayerBeiginPlay()
    @objc optional func UUAVAudioPlayerDidFinishPlay()
    @objc optional func UUAVAudioPlayerFault()
}

class UUAVAudioPlayer: NSObject {
    
    var player: AVAudioPlayer?
    weak var delegate: UUAVAudioPlayerDelegate?
    
    static let shared = UUAVAudioPlayer()
    
    func play(songUrl: String) {
        DispatchQueue(label: "playSoundFromUrl").async {
            self.delegate?.UUAVAudioPlayerBeiginLoadVoice?()
            if let url = URL(string: songUrl),
                let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.play(songData: data)
                }
            }
        }
    }
    
    func play(voiceURL: URL) {
        DispatchQueue(label: "playSoundFromUrl").async {
            self.delegate?.UUAVAudioPlayerBeiginLoadVoice?()
            if let data = try? Data(contentsOf: voiceURL) {
                DispatchQueue.main.async {
                    self.play(songData: data)
                }
            } else {
                self.delegate?.UUAVAudioPlayerFault?()
            }
        }
    }
    
    
    func play(songData: Data) {
        self.setupPlaySound()
        self.play(soundData: songData)
    }
    
    func stop() {
        if let _player = self.player, _player.isPlaying {
            _player.stop()
        }
    }
    
    private func play(soundData: Data) {
        if player != nil {
            player?.stop()
            player?.delegate = nil
            player = nil
        }
        
        do {
            player = try AVAudioPlayer(data: soundData)
            player?.volume = 1.0
            player?.delegate = self
            player?.play()
            self.delegate?.UUAVAudioPlayerBeiginPlay?()
        } catch {
            print("ERror creating player: %@", error)
        }
    }
    
    private func setupPlaySound() {
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: .UIApplicationWillResignActive, object: app)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }
    
    
    @objc private func applicationWillResignActive(_ application: UIApplication) {
        self.delegate?.UUAVAudioPlayerDidFinishPlay?()
    }
    
}


extension UUAVAudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.UUAVAudioPlayerDidFinishPlay?()
    }
}
