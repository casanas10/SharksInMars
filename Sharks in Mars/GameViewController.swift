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
import GoogleMobileAds

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()
    
    var googleBannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        //        googleBannerView.adUnitID = "ca-app-pub-4495197822490037/4973686123"
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        googleBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.googleBannerView.rootViewController = self;
        let request: GADRequest = GADRequest()
        self.googleBannerView.load(request)
        
        googleBannerView.frame = CGRect(x: view.frame.size.width/2 - googleBannerView.frame.size.width/2, y: view.frame.size.height - googleBannerView.frame.size.height, width: googleBannerView.frame.size.width,height: googleBannerView.frame.size.height)
        
        self.view.addSubview(googleBannerView)

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
