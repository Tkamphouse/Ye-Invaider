//
//  GameScene.swift
//  Ye Invaiders
//
//  Created by Tyler Kamphouse on 5/3/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // *** Properties ***
    var gameArea = CGRect()
    var maxAspectRatio = CGFloat()
    var playWidth = CGFloat()
    var playHeight = CGFloat()
    var margin = CGFloat()
    
    // Visual Properties
    let player = SKSpriteNode(imageNamed: "kanyeFace")
    let background = SKSpriteNode(imageNamed: "background")
    let laserSound = SKAction.playSoundFileNamed("Augggh.mp3", waitForCompletion: false)
    
    
    // *** Constructors ***
    override init(size: CGSize){
        maxAspectRatio = 16.0/9.0
        playWidth = size.height/maxAspectRatio
        playHeight = size.height/4
        margin = (size.width - playWidth)/2
        gameArea = CGRect(x: margin, y: 30, width: playWidth, height: playHeight)
        print(" (GameScene) Used Overloaded Constructor")
        
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        print(" (GameScene) You just used this stupid constuctor, fix that")
    }
    
    // *** Methods ***
    // Initialize Screen
    override func didMove(to view: SKView){
        
        // Setup Physics
        self.physicsWorld.contactDelegate = self
        
        // Background
        background.size = self.size
        background.zPosition = 0
        
        // Player
        player.setScale(0.15)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCatagories.Player
        player.physicsBody!.collisionBitMask = PhysicsCatagories.None
        player.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy | PhysicsCatagories.EnemyLaser

        
        // Position Assets
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        player.position = CGPoint(x: self.size.width/2, y: 100)
        
        // Add Assets
        self.addChild(background)
        self.addChild(player)
        
        // Spawn Enemies
        startNewLevel()
    }
    
    // Handles object contact
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // if player hits enemy
        if body1.categoryBitMask == PhysicsCatagories.Player && body2.categoryBitMask == PhysicsCatagories.Enemy {
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            print("contact A")
        }
        // if laser hits enemy
        if body1.categoryBitMask == PhysicsCatagories.Laser && body2.categoryBitMask == PhysicsCatagories.Enemy {
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            print("contact B")
        }
        // if laser hits enemyLaser
        if body1.categoryBitMask == PhysicsCatagories.Laser && body2.categoryBitMask == PhysicsCatagories.EnemyLaser {
            //l8r
        }
        // if player hits enemyLaser
        if body1.categoryBitMask == PhysicsCatagories.Player && body2.categoryBitMask == PhysicsCatagories.EnemyLaser {
            //l8r
        }
    }
    
    // Start New Level
    func startNewLevel(){
        
        let spawn = SKAction.run(spawnEnemy)
        let spawnWait = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, spawnWait])
        let spawnLoop = SKAction.repeatForever(spawnSequence)
        self.run(spawnLoop)
    }
    
    // Fire Laser
    func fireLaser(){
        
        // Laser
        let laser = SKSpriteNode(imageNamed: "laser")
        laser.setScale(0.05)
        laser.position = player.position
        laser.zPosition = 1
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody!.affectedByGravity = false
        laser.physicsBody!.categoryBitMask = PhysicsCatagories.Laser
        laser.physicsBody!.collisionBitMask = PhysicsCatagories.None
        laser.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy | PhysicsCatagories.EnemyLaser

        
        self.addChild(laser)
        
        let moveLaser = SKAction.moveTo(y: self.size.height + laser.size.height, duration: 1)
        let deleteLaser = SKAction.removeFromParent()
        let laserSequence = SKAction.sequence([laserSound, moveLaser, deleteLaser])
        laser.run(laserSequence)
    }
    
    // Spawn Enemy
    func spawnEnemy(){
        
        let startX = random(min: gameArea.minX, max: gameArea.maxX)
        let endX = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: startX, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: endX, y: -self.size.height * 0.2 )
        
        let enemy = SKSpriteNode(imageNamed: "peteEnemy")
        enemy.setScale(0.2)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCatagories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCatagories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCatagories.Player | PhysicsCatagories.Laser
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let changeX = endPoint.x - startPoint.x
        let changeY = endPoint.y - startPoint.y
        let rotation = atan2(changeY, changeX)
        enemy.zRotation = rotation
    }
    
    // When Tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        fireLaser()
    }
    
    // When Tap held or dragged
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let touchLocation = touch.location(in: self)
            let prevTouchLocation = touch.previousLocation(in: self)
            
            let changeX = touchLocation.x - prevTouchLocation.x
            let changeY = touchLocation.y - prevTouchLocation.y
            
            player.position.x += changeX
            player.position.y += changeY
            
            // maintain player in gameZone
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
            if player.position.y > gameArea.maxY {
                player.position.y = gameArea.maxY
            }
            if player.position.y < gameArea.minY {
                player.position.y = gameArea.minY
            }
        }
    }
    
}


    
    
