//
//  GameViewController.swift
//  Sharks in Mars
//
//  Created by alejandro casanas on 8/9/17.
//  Copyright © 2017 alejandro casanas. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "BossMain", ofType: "wav")
        let audioURL = URL(fileURLWithPath: filePath!)
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioURL)
        } catch {
            return print("Cannot find the audio")
        }
        
        backingAudio.numberOfLoops = -1 //loop forever
        backingAudio.volume = 0.5
        backingAudio.play()
        
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true;
        
        scene.scaleMode = .aspectFill
        
        // Present the scene
        skView.presentScene(scene)
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
