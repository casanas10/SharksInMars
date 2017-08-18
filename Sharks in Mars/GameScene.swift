//
//  GameScene.swift
//  Sharks in Mars
//
//  Created by alejandro casanas on 8/9/17.
//  Copyright © 2017 alejandro casanas. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "shark")
    
    let bulletSound = SKAction.playSoundFileNamed("bulletSound.wav", waitForCompletion: false)
    
    let explosionSound = SKAction.playSoundFileNamed("explosionSound.wav", waitForCompletion: false)
    
    
    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    var level = 0
    var livesNum = 3
    var livesLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    let tapToBeignLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    enum gameState {
        case PRE_GAME
        case IN_GAME
        case AFTER_GAME
    }
    
    var currentGameState = gameState.PRE_GAME
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1
        static let Bullet: UInt32 = 0b10
        static let Enemy: UInt32 = 0b100
    }
    
    //set up the playable area for the game
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
 
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.88, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToBeignLabel.text = "Tap To Start"
        tapToBeignLabel.fontSize = 100
        tapToBeignLabel.fontColor = SKColor.white
        tapToBeignLabel.zPosition = 1
        tapToBeignLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToBeignLabel.alpha = 0
        self.addChild(tapToBeignLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToBeignLabel.run(fadeInAction)
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if (gameScore == 10 || gameScore == 25 || gameScore == 50) {
            startNewLevel()
        }
    }
    
    func loseLife() {
        livesNum -= 1
        livesLabel.text = "Lives: \(livesNum)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNum == 0 {
            runGameOver()
        }
    }
    
    func runGameOver() {
        
        currentGameState = gameState.AFTER_GAME
        
        //freeze the game and fade into game over scene
        self.removeAllActions()     //stop sequence spawning enemies
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScence)
        let waitToChangeScence = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScence, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    func changeScence() {
        let sceneToMoveTo = GameOverScence(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let fadeTransition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(sceneToMoveTo, transition: fadeTransition)
    }
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet2")
        bullet.name = "Bullet"  //reference name
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    //UTILITIES FUNC
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //get random number between range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "humans_ship")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseLife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if (currentGameState == gameState.IN_GAME){
            enemy.run(enemySequence)
        }
        
        //rotate enemy ship
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        
        let amountToRotate = atan2(dy, dx)
        
        enemy.zRotation = amountToRotate
    }
    
    func startNewLevel() {
        
        level += 1
        
        if (self.action(forKey: "spawningEnemies") != nil) {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch level {
        case 1:
            levelDuration = 1.1
        case 2:
            levelDuration = 0.8
        case 3:
            levelDuration = 0.5
        case 4:
            levelDuration = 0.2
        default:
            levelDuration = 0.5
            print("cannot find level info")
            
        }
        
        //run spawn enemy
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey:"spawningEnemies")
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody() //lowest category number
        var body2 = SKPhysicsBody() //highest category number
        
        //grab category numbers and order numerically
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        //if player has hit the enemy
        if (body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy) {
            
            print("player hit enemy")
            
            if (body1.node != nil){
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if (body2.node != nil) {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        //if bullet has hit the enemy and enemy is on the screen
        if (body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy) {
            
            if (body2.node != nil) {
                if (body2.node?.position.y)! < self.size.height {
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
                
                addScore()
                
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
            }
        }
    }
    
    func startGame() {
        currentGameState = gameState.IN_GAME
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToBeignLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.15, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (currentGameState == gameState.PRE_GAME){
            startGame()
        } else if (currentGameState == gameState.IN_GAME){
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if (currentGameState == gameState.IN_GAME){
                player.position.x += amountDragged
            }
        
            //if gone too far to right
            if (player.position.x > gameArea.maxX - player.size.width/2) {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            //if too far to left
            if (player.position.x < gameArea.minX + player.size.width/2) {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
