//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Meghan Walley on 12/10/19.
//  Copyright © 2019 Meghan Walley. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode {

    // Create a Heads-Up-Display (HUD) that will hold all our display areas.
    //
    // Once the node is added to the scene, we'll tell it to lay out its
    // child nodes.  The child nodes will not contain labels as we will use
    // the blank nodes as group container and lay out the label nodes inside
    // of them.
    //
    // We will left-align our score and right-align the elapsed game time.
    //
    
    // MARK: - Constants
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "showPowerupTimer"
    
    private let HealthGroupName = "healthGroup"
    private let HealthValueName = "healthValue"
    
    
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    
    override init() {
        super.init()
        
        createScoreGroup()
        createElapsedGroup()
        createPowerupGroup()
        createHealthGroup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //
    // Our labels are properly layed out within their parent group nodes,
    // but the group nodes are centered on the scene.  We need to create
    // a layout method that will properly position the groups.
    //
    func layoutForScene() {
        
        if let scene = scene {
            
            let sceneSize = scene.size
            
            // The following will be used to calculate position of each group
            var groupSize = CGSize.zero
            var scoreSize = CGFloat()
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 30.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No score group node was found in the Scene Graph node tree")
            }
            
            
            if let elapsedGroup = childNode(withName: ElapsedGroupName) {
                
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 30.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No elapsed group node was found in the Scene Graph node tree")
            }
            
            
            
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                scoreSize = groupSize.height // used for placinghealthgroup
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height - 40.0)
            } else {
                assert(false, "No power-up group node was found.")
            }
            
            if let healthGroup = childNode(withName: HealthGroupName) {
                groupSize = healthGroup.calculateAccumulatedFrame().size
                
                healthGroup.position = CGPoint(x: -sceneSize.width/2.0 + 40.0, y: sceneSize.height/2.0 - (groupSize.height + scoreSize + CGFloat(sceneSize.height/20)))
                
            } else {
                assert(false, "No Health Group Node was found in Node Tree")
        }
        
    }
}
    
    func createScoreGroup() {
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Create an SKLabelNode for our title
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help use layout for the labels inside this group node.
        scoreTitle.horizontalAlignmentMode = .center
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help use layout for the labels inside this group node.
        scoreValue.horizontalAlignmentMode = .center
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        
        // Add scoreGroup as a child of our HUD node
        addChild(scoreGroup)
        
    }
    
    
    func createElapsedGroup() {
        
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // create an SKLabelNode for title
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment nodes in a way
        // that will help use layout for the labels inside this group node.
        elapsedTitle.horizontalAlignmentMode = .center
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment nodes in a way
        // that will help use layout for the labels inside this group node.
        elapsedValue.horizontalAlignmentMode = .center
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        addChild(elapsedGroup)
        
    }
    
    
    
    // Create createPowerupGroup() method
    
     func createPowerupGroup() {
     
         let powerupGroup = SKNode()
         powerupGroup.name = PowerupGroupName
     
         let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
     
         powerupTitle.fontSize = 14.0
         powerupTitle.fontColor = SKColor.red
     
         powerupTitle.verticalAlignmentMode = .bottom
         powerupTitle.text = "Power-up!"
         powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
     
         let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
         let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
     
         let pulse = SKAction.sequence([scaleUp, scaleDown])
     
         let pulseForever = SKAction.repeatForever(pulse)
     
         powerupTitle.run(pulseForever)
     
         powerupGroup.addChild(powerupTitle)
     
         let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
     
         powerupValue.fontSize = 20.0
         powerupValue.fontColor = SKColor.red
     
         powerupValue.verticalAlignmentMode = .top
         powerupValue.name = PowerupValueName
         powerupValue.text = "0s left"
         powerupValue.position = CGPoint(x: 0.0, y: -4.0)
     
         powerupGroup.addChild(powerupValue)
     
         addChild(powerupGroup)
     
         powerupGroup.alpha = 0.0
     }
 
 
    // create healthGroup() method
    func createHealthGroup () {
    
        let healthGroup = SKNode()
        healthGroup.name = HealthGroupName
        
        // sklabel for title
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        healthTitle.fontSize = 14.0
        healthTitle.fontColor = SKColor.yellow
        
        // set vertical and horizontal alignment nodes in a way
        // that will help use layout for the labels inside this group node.
        healthTitle.horizontalAlignmentMode = .left
        healthTitle.verticalAlignmentMode = .bottom
        
        healthTitle.text = "HEALTH"
        
        healthTitle.position = CGPoint(x:0.0, y: 4.0)
        healthGroup.addChild(healthTitle)
        
        let healthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        healthValue.fontSize = 20.0
        
        healthValue.fontColor = SKColor.yellow
        
        healthValue.horizontalAlignmentMode = .left
        healthValue.verticalAlignmentMode = .top
        
        healthValue.name = HealthValueName
        healthValue.text = "50%"
        
        healthValue.position = CGPoint(x:0.0, y: -4.0)
        healthGroup.addChild(healthValue)
        
        addChild(healthGroup)
    }
    

    
    
    
    func addPoints(_ points: Int) {
        
        score += points
        
        // Update the HUD by looking up scoreValue label and updating it
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            // Scale the node up for a brief period of time and then
            // scale it back down
            
            let scale = SKAction.scale(to: 1.1, duration: 0.02)
            let shrink = SKAction.scale(to: 1.0, duration: 0.07)
            
            scoreValue.run(SKAction.sequence([scale, shrink]))
            
            
        }
        
    }
    
    // showPowerupTimer() method - called from checkCollisions
    // when ship intersects with a powerup.
    
    func showPowerupTimer(_ time: TimeInterval) {
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            if let powerupValue =  powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                let start = NSDate.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsed = NSDate.timeIntervalSinceReferenceDate - start
                        let left = max(time - elapsed, 0)
                        let leftFmt = weakSelf.timeFormatter.string(from: NSNumber(value: left))!
                        
                        powerupValue.text = "\(leftFmt)s left"
                    }
                }
                
                let blockPause = SKAction.wait(forDuration: 0.05)
                let countDownSequence = SKAction.sequence([block, blockPause])
                let countDown = SKAction.repeatForever(countDownSequence)
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                let wait = SKAction.wait(forDuration: time)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run({ () -> Void in
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                })
                
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
            }
        }
    }
    
    
    
    func startGame() {
        
        // Calculate the timestamp when starting the game
        let startTime = Date.timeIntervalSinceReferenceDate
        
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            
            // Use a code block to update the elapsedTime property to
            // be the difference between the startTime and the current
            // timestamp.
            let update = SKAction.run {
                [weak self] in
                
                if let weakSelf = self {
                    
                    let currentTime = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = currentTime - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.string(from: NSNumber(value: weakSelf.elapsedTime))
                    
                }
            }
            
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
            
        }
        
    }
    
    
    func endGame() {
        
        // Stop the timer sequence
        removeAction(forKey: TimerActionName)
        
        // Clean up any Powerup timer
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            powerupGroup.run(fadeOut)
            
        }
        
    }
    
    func showHealth(_ health: Double) {
        //Look up score value
        if let healthValue = childNode(withName: "\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            // formatter
            healthValue.text = "\(100 * (health / 4))%"
            //scale node up then down
            healthValue.run(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.04), SKAction.scale(to: 1.0, duration: 0.07)]))
            
        }
    }
}

