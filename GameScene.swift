//
//  GameScene.swift
//  SpaceRun
//
//  Created by Meghan Walley on 11/26/19.
//  Copyright © 2019 Meghan Walley. All rights reserved.
//
import SpriteKit
//import GameplayKit

class GameScene: SKScene {
    
    //class property
   static var shipHealthRate: Double = 2.0
    
    // Property constants
    private let SpaceshipNodeName = "ship"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HUDNodeName = "hud"
    private let HealthPowerupNodeName = "healthPowerup"
    
    // Properties to hold sound actions. We will be preloading the sounds
    // into these properties so there is no delay when they are implemented
    // for the first time.
    private let shootSound: SKAction =
        SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    
    // We will be using the explosion particle emitters repeatedly.  We
    // don't want to load them from the .sks files every time we need them,
    // so instead we'll create properties and load them from cache memory
    // for quick reuse much like we did for our sound properties.
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obstacleExplode.sks")!
    
    
    // Property variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    
    private let defaultFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    private var shipFireRate: Double = 0.5
    
    
    
    // TODO: Set up custom initializer for this class
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // TODO: Define setupGame() method
    func setupGame(_ size: CGSize) {
        
        let ship = SKSpriteNode(imageNamed: "mousepic.png")
        ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        ship.size = CGSize(width: 40.0, height: 40.0)
        ship.name = SpaceshipNodeName
        addChild(ship)
        
        
        // Add ship thruster particle to our ship
        if let thruster = SKEmitterNode.nodeWithFile("thruster.sks") {
            thruster.position = CGPoint(x: 0.0, y: -20.0)
            
            // Add thruster as a child of our ship
            ship.addChild(thruster)
        }
        
        // Set up our HUD
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        
        hudNode.zPosition = 100.0
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(hudNode)
        
        hudNode.layoutForScene()
        
        // Start the game
        hudNode.startGame()
        
        // Add the star field parallax effect by creating an instance
        // of our StarField class and adding it as a child of our scene
        addChild(StarField())
        
    }
    
    
    //
    // Called automatically when a touch occurs
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // TODO: fill in code for responding to a touch
        if let touch = touches.first {
            /*let touchPoint = touch.location(in: self)
            
            if let ship = self.childNode(withName: SpaceshipNodeName) {
                ship.position = touchPoint
            }*/
            
            self.shipTouch = touch
        }
        
    }
 
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        // TODO: fill in code that should run framerate times per second
        
        if let shipTouch = shipTouch {
            
            /*if let ship = self.childNode(withName: SpaceshipNodeName) {
                ship.position = shipTouch.location(in: self)
            }*/
            
            moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                lastShotFireTime = currentTime
            }
            
        }
        
        // Release obstacles 1.5% of the time
        if arc4random_uniform(1000) <= 15 {
            
            dropThing()
            
        }
        
        checkCollisions()
        
        
        // Reset lastUpdateTime to currentTime
        lastUpdateTime = currentTime
        
    }
    
    
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Points per second that the ship should travel
        let shipSpeed = CGFloat(230)
        
        // Re-obtain a reference to our ship sprite from the scene's
        // Scene Graph Node Tree.
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            
            // TODO: fill in code for each of the tasks explained by comments

            // Determine the distance between the ship's current location
            // and the touch point using the Pythagorean theorem.
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // If distance remaining is greater than 4 points, keep moving
            // the ship toward the touch point.  Otherwise, stop the ship.
            // If we don't stop the ship, it may "jitter" around the touch
            // point due to imprecision with floating point numbers.
              // keep moving the ship
            if distanceLeftToTravel > 4 {

                // Calculate how far we should move the ship during this frame
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
                
                // Convert the distance remaining back into (x,y) coordinates
                // using atan2() to determine the proper angle based on the
                // ship's position and the touch point destination.
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Then, using the angle along with sin() and cos() functions,
                // determine the x and y offset values (distances to move
                // along these axes)
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                // Use the offset values to reposition the ship for this
                // frame moving it a little closer to the touch point.
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }
            
        }
        
    }
    
    
    //
    // Shoot a photon torpedo
    //
    // TODO: Define shoot() method
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Create our photon torpedo sprite node
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoNodeName)
            
            photon.name = PhotonTorpedoNodeName
            photon.position = ship.position
            
            self.addChild(photon)
            
            // Set up actions for the photon sprite
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
            
        }
        
    }
    
    
    //
    // Drop something from the top of the scene
    //
    // TODO: Define dropThing() method
    func dropThing() {
        
        // Simulate a die roll from 0-99
        let dieRoll = arc4random_uniform(100)
        
        if dieRoll < 15 {
            dropPowerUp()
        } else if dieRoll < 30 {
            dropEnemyShip()
            dropHealth()
        } else {
           dropAsteroid()
        }
        
    }
    
    
    //
    // Drop an asteroid obstacle onto the scene
    //
    // TODO: Define dropAsteroid() and dropHealth() method
    func dropHealth() {
        let sideSize = 20.0
        
        // different than enemy ship
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 20)
        
        // starting y position
        let startY = Double(self.size.height) + sideSize
        
        // Create a health sprite
        let healthPowerUp = SKSpriteNode(imageNamed: "cheese.png")
        healthPowerUp.name = HealthPowerupNodeName
        healthPowerUp.size = CGSize(width: sideSize, height: sideSize)
        healthPowerUp.position = CGPoint(x: startX, y: startY)
        self.addChild(healthPowerUp)

        let healthPowerUpPath = createBezierPath()

        let followPath = SKAction.follow(healthPowerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()

        let fadeAndScale = SKAction.group([SKAction.fadeOut(withDuration: 5.0), SKAction.scale(to: 0.5, duration: 4.0)])
        
        healthPowerUp.run(SKAction.group([SKAction.sequence([SKAction.wait(forDuration: 1.5), fadeAndScale]), SKAction.sequence([followPath, remove])]))
    }
    
    func dropAsteroid() {
        
        // Define asteroid size to be a random number between 15 and 45
        let sideSize = Double(15 + arc4random_uniform(31))
        
        // maximum x-position for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        // Determine random starting point for the asteroid
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX*2)))) - quarterX
        let startY = Double(self.size.height) + sideSize  // above top edge
        
        // Determine ending position of asteroid
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize   // below bottom edge of scene
        
        // Create asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "cat.png")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Get the asteroid moving using actions
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + arc4random_uniform(5)))
        
        let remove = SKAction.removeFromParent()
        
        // Rotate the asteroid by 3 radians (just less than 180 degrees)
        // over a 1-3 second duration
        let spin = SKAction.rotate(byAngle: 3, duration: Double(1 + arc4random_uniform(3)))
        
        let spinForever = SKAction.repeatForever(spin)
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.run(all)
        
    }
    
    
    //
    // Drop an enemy ship
    //
    func dropEnemyShip() {
        
        // Define enemy ship size
        let sideSize = 30.0
        
        // Determine a random starting point
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 40)) + 20)
        let startY = Double(self.size.height) + sideSize  // above top edge
        
        // Create enemy ship sprite
        let enemy = SKSpriteNode(imageNamed: "mousetrap")
        
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        // Get the enemy ship moving
        // TODO: Create the path we will fly the ship along
        let shipPath = createBezierPath()
        
        // Perform actions to fly our ship along the path
        //
        // asOffset: a value of true lets us treat the action point values
        //           of the path as offsets from the enemy ship's starting point.
        //           A value of false would treat the path's points as absolute
        //           positions on the screen.
        //
        // orientToPath: a value of true causes the enemy ship to turn and
        //               face the direction of the path automatically
        
        // TODO: fly our ship along the generated path
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        enemy.run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
        
    }
    
    
    
    
    
    //
    // Create flight path for enemy ships to follow
    //
    func createBezierPath() -> CGPath {
        
        let yMax = -1.0 * self.size.height
        
        // Bezier path uses two control points along a line to
        // create a curved path.  We will use the UIBezierPath class
        // to build this kind of object.
        //
        // Bezier path produced using the PaintCode app (www.paintcodeapp.com)
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
        
    }
    
    
    //
    // Drop a weapons powerup
    //
    // TODO: Define dropPowerUp() method
    func dropPowerUp() {
        
        let sideSize = 30.0
        
        // Determine a random starting point
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize  // above top edge
        
        // Create weapons powerup sprite
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        let powerUpPath = createBezierPath()
        
        // Perform actions to fly our powerup along the path
        //
        // asOffset: a value of true lets us treat the action point values
        //           of the path as offsets from the enemy ship's starting point.
        //           A value of false would treat the path's points as absolute
        //           positions on the screen.
        //
        // orientToPath: a value of true causes the enemy ship to turn and
        //               face the direction of the path automatically
        
        powerUp.run(SKAction.sequence([SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
        
    }
    
    

    func checkCollisions() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // TODO: add collision for weapons powerup later here...
            // If the ship bumps into a weapons powerup, remove the powerup from the scene
            // and reset the shipFireRate to 0.1 to increase the ship's fire rate.
            enumerateChildNodes(withName: HealthPowerupNodeName) {
                myHealthPowerup, _ in

                
                if ship.intersects(myHealthPowerup) {
                    GameScene.shipHealthRate = 4.0
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showHealth(GameScene.shipHealthRate)
                    }
                    myHealthPowerup.removeFromParent()
                }
            }

            enumerateChildNodes(withName: PowerupNodeName) {
                myPowerUp, _ in
                
                if ship.intersects(myPowerUp) {
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showPowerupTimer(self.powerUpDuration)
                    }
                    
                    myPowerUp.removeFromParent()
                    
                    // Increase the ship's fire rate
                    self.shipFireRate = 0.1
                    
                    let powerDown = SKAction.run({
                        self.shipFireRate = self.defaultFireRate   // reset to slower normal fire rate
                    })
                    
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    
                    //ship.run(SKAction.sequence([wait, powerDown]))
                    
                    // If we collect an additional powerup while one is already
                    // in progress, we need to stop the one in progress and start
                    // a new one so we always get the full duration for the new one.
                    //
                    // Sprite Kit lets us run actions with a key that we can then use
                    // to identify and remove the action before it has a chance to run
                    // or before it finishes if it is already running.
                    //
                    // If no key is found, nothing happens...
                    //
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    
                    ship.run(SKAction.sequence([wait, powerDown]), withKey: powerDownActionKey)
            
                    
                }
                
            }
            
            // Loop through all instances of obstacle nodes in the
            // Scene Graph node tree
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle, _ in
                
                // TODO: add collision check for ship vs obstacle
                if ship.intersects(obstacle) {
                    
                    // ship, obstacle, and the touch event (UITouch) should all go away
                    self.shipTouch = nil
                    
                    if GameScene.shipHealthRate > 0 {
                    obstacle.removeFromParent()

                    // update health
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        GameScene.shipHealthRate = GameScene.shipHealthRate - 1.0
                        hud.showHealth(GameScene.shipHealthRate)
                    }
                    
                    
                    // We need to call the copy() method on the shipExplodeTemplate
                    // object because SKEmitterNodes can only be added once to a
                    // scene.
                    //
                    // If we try to add a node again that already exists in the
                    // scene, the game will crash with an error.  We will use
                    // emitter node template in our cached property as a template
                    // from which to make copies.
                    let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                    
                    explosion.position = ship.position
                    explosion.dieOutInDuration(0.3)
                    self.addChild(explosion)
                        // remove ship only if health is 0.0%
                        if (GameScene.shipHealthRate == 0.0) {
                            ship.removeFromParent()
                        }
                       
                    obstacle.removeFromParent()
                    
                    self.run(self.shipExplodeSound)
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.endGame()
                    }
                    
                }
                }
                
                // Since we are inside a closure, we need to use self to
                // reference our class because the closure affects scope.
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName) {
                    myPhoton, stop in
                    
                    // TODO: add collision check for photon torpedo vs obstacle
                    // Note: this is indented to show this should take place inside
                    //       collision check for ship vs obstacle
                    if myPhoton.intersects(obstacle) {
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        self.run(self.obstacleExplodeSound)
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            hud.addPoints(100)
                        }
                        
                        // This is like a break statement in other languages
                        stop.pointee = true
                        
                    }
                    
                }
                
                
            }  // end enumerateChildNodes() for obstacle
            
        }
        
    }
    
}

