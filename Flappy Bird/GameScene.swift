//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Harry Ferrier on 8/18/16.
//  Copyright © 2016 CASTOVISION LIMITED. All rights reserved.
//

import SpriteKit
import GameplayKit


// In order to use physics (gravity) in the game, call the SKPhysicsContactDelegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Create a global instance of SKSpriteNode named bird. This will be flappy bird.
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var score = 0
    
    var gameOver: Bool = false
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    
    // CollderType enum with an established raw value of type UInt32. This enum will establish contact between the bird and other objects on the screen.
    
    enum ColliderType: UInt32 {
    
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
   
    
    // Make pipes function
    
    func makePipes() {
        
        // Set the gap between the pipes to be 4 times larger than the height of the bird sprite
    
        let gapHeight = bird.size.height * 4
        
        
        // Randomise how the pipe will appear in relation to the center of the screen.
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        // And set it so that the pipe will move to a maximum of 3/4 of the screen's height, and a minimum of a 1/4 of the screen's height.
        
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        
        
        // Move the pipes from right to left across the screen with a speed that depends on the device's width.
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        
        
        
        // *** MAKING THE PIPES *** //
        
        // Set up the pipe1 (the top pipe) sprite and it's image...
        
        let pipe1Texture = SKTexture(imageNamed: "pipe1")
        
        let pipe1 = SKSpriteNode(texture: pipe1Texture)
        
        
        // Set it's height, factoring the offset and the gapHeight for the bird to get through the center..
        
        pipe1.position = CGPoint(x: self.frame.midY + self.frame.width, y: self.frame.midY + pipe1Texture
            .size().height / 2 + gapHeight / 2 + pipeOffset)
        
        
        // Set a physics body around the shape of the bird.
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        
        // Do not allow gravity to affect the pipe
        
        pipe1.physicsBody?.isDynamic = false
        
        
        // Set BitMask tests using the values set in the ColliderType enum..
        
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        
        // Start the action of moving the pipe1 sprite..
        
        pipe1.run(movePipes)
        
        // Add it to the screen.
        
        self.addChild(pipe1)
        
        
        
        
        // Set up pipe2 sprite (the bottom pipe) with it's appropriate texture
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2")
        
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        
        
        // Set the pipe's position from the bottom of the device screen, factoring in the gapheight and pipeOffset
        
        pipe2.position = CGPoint(x: self.frame.midY + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        
        
        // Add a physics body to the sprite which emcompasses it's texture shape.
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        
        // Do not allow gravity to affect the pipe2 sprite.
        
        pipe2.physicsBody?.isDynamic = false
        
        
        // Set BitMask tests using the values set in the ColliderType enum..
        
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        
        // Run the action to move the pipe
        
        pipe2.run(movePipes)
        
        
        // Add the sprite to the device view.
        
        self.addChild(pipe2)
        

        
        
        // ** CREATE GAP FOR THE BIRD TO FLY THROUGH ** //
        
        
        let gap = SKNode()
        
        // Set the position of the gap using the pipeOffset to manipulate it..
        
        gap.position = CGPoint(x: self.frame.midY + self.frame.width, y: self.frame.midY + pipeOffset)
        
        
        // Add a physics body to the gap, which will be a rectangle which sits flush in between the two pipes..
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
    
        
        // Do not allow gravity to affect the gap..
        
        gap.physicsBody?.isDynamic = false
        
        // Run the animation to move the gap from right to left..
        
        gap.run(movePipes)
        
        
        // set BitMask test to determine contact between the bird and the gap.
        
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        
        // Add the invisible gap node to the device screen.
        
        self.addChild(gap)
    }
    
    
    
    // didBegin function...
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        // If gameOver is equal to false...
        
        if gameOver == false {
        
            // Identify if the categoryBitMask of either bodyA or bodyB has the same raw value specific for the 'Gap' case in the 'ColliderType' enum (4)....and if it doess...
            
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
                
                // Add 1 to the score variable..
                
                score += 1
                
                // Display the score in the scoreLabel
                
                scoreLabel.text = String(score)
            
                
            // If the contact type was not equal to the gap (so the bird has hit either a pipe or the ground..
                
            } else {
            
                
                // Stop the animation and bring the screen to a halt..
                
                self.speed = 0
            
                // Specify that the game is over..
                
                gameOver = true
                
                // Stop the timer (therefore preventing the game from randomly creating more pipes...
                
                timer.invalidate()
                
                
                // Set up the details for the gameOverLabel..
                
                gameOverLabel.fontName = "Helvetica"
                
                gameOverLabel.fontSize = 40
                
                gameOverLabel.text = "Game Over! Tap to play again"
                
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                gameOverLabel.zPosition = 1
                
                // Display the gameOverLabel on the screen..
                
                self.addChild(gameOverLabel)
                
            }
            
        }
        
    }
    
    
    
    // setupGame function which...
    
    func setupGame() {
    
        // Begins the timer and calls the 'makePipes' function once every 3 seconds on repeat..
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        
        
        
        // *** MAKING THE BACKGROUND *** //
        
        // Set up the background and assign it it's appropriate texture (image)..
        
        let bgTexture = SKTexture(imageNamed: "bg")
        
        
        // Move the background screen from right to left with a completion duration of 7 seconds..
        
        let moveBackgroundAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        
        
        // Create another background image to piggy back on the back of the first background image, appearing instantly.
        
        let shiftBackground = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        
        // Set the animations above to repeatForever aslong as the game is in progress.
        
        let createFlyingIllusion = SKAction.repeatForever(SKAction.sequence([moveBackgroundAnimation, shiftBackground]))
        
        
        // Create a counter variable of type CGFloat for use within the while loop below..
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            // Create background image and set it's texture..
            
            background = SKSpriteNode(texture: bgTexture)
            
            // Stack the background images from right to left (off the right edge of the screen 3 times(using the value of the i counter))
            
            background.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            // Set the height to be equal to the device's height.
            
            background.size.height = self.frame.height
            
            
            // Run the animation on the background.
            
            background.run(createFlyingIllusion)
            
            // Specify that it will be at the back of the zposition list so that pipes and bird etc will appear infront of it.
            
            background.zPosition = -1
            
            
            // Add the background to the device's screen.
            
            self.addChild(background)
            
            // Increment the i counter value by 1 each time the loop runs to prevent an infinity loop.
            
            i += 1
            
        }
        
        
        
        
        
        
        // *** MAKING THE FLAPPY BIRD *** //
        
        
        // Similar to a GIF video, create contants for each image frame that you wish to animate through.
        
        let birdTexture1 = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        
        // Create an animation instance of SKAction's animate property. Fill with with array with the variable names of the images you wish to loop through, and specify the time per frame..
        
        let animation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.1)
        
        // Create another instance, this time of the SKAction's repeat forever property, and call the 'animation' instance as it's parameter.
        
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        
        
        // Set the spite node's texture to be the initial bird texture..
        
        bird = SKSpriteNode(texture: birdTexture1)
        
        
        
        // Center it in the screen..
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // Run the animation on it..
        
        bird.run(makeBirdFlap)
        
        
        // Create a physics body on the bird which will be a circle surrounding the bird's image..
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height / 2)
        
        // Prevent gravity from affecting the bird initially.
        
        bird.physicsBody?.isDynamic = false
        
        // Set up bitmask queries on the bird to establish contact between the bird on the gap, pipes or ground.
        
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        
        
        // Add it to the view..
        
        self.addChild(bird)
        
        
        
        
        
        
        
        // *** MAKING THE GROUND *** //
        
        // Create the ground using SKNode()
        
        let ground = SKNode()
        
        // Set the ground to be at the bottom of the screen, across the whole width of the device screen.
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        // Set a physics body on teh ground node which is only 1 pixel in height.
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        
        // Prevent gravity from having an effect on the ground.
        
        ground.physicsBody?.isDynamic = false
        
        
        // Set up BitMask queries to establish when it has come in contact with another object (in the case of our game, it can only be the bird..
        
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        
        // Add the ground to the view..
        
        self.addChild(ground)
        
        
        
        // Create the scoreLabel and establish it's font size, height, text value, position (at top of device screen) and zPosition value..
        
        scoreLabel.fontName = "Helvetica"
        
        scoreLabel.fontSize = 60
        
        scoreLabel.text = "0"
        
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        scoreLabel.zPosition = 1
        
        
        // Add the scoreLabel to the view..
        
        self.addChild(scoreLabel)
    
    }
    
    
    
    // didMove function...
    
    override func didMove(to view: SKView) {
        
        // Set the contact delegate of the physics world to be the view itself.
        
        self.physicsWorld.contactDelegate = self
        
        // Call the setupGame function..
        
        setupGame()
        
    }
    
    
    
    // touchesBegan method which runs when the user first touches the device screen..
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        // Check if the game is still in flow...if so...
        
        if gameOver == false {
        
            // Change the isDynamic physicsBody property of the bird to true, so that it will be affected by gravity and want to drop to the bottom of the screen..
            
            bird.physicsBody!.isDynamic = true
        
            // Set the velocity of the gravity set on the bird to be normal affects of gravity..
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
            
            // Add a jolting impulse to the bird when the screen is tapped which will bounce the bird upwards by 60 pixels..
            
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
       
            
        // If the game is over (so the bird has come into contact with either the pipes of the ground...
        
        } else {
        
            
            // Change the gameOver to be false...
            
            gameOver = false
            
            // Set the user's score back to zero..
            
            score = 0
            
            // Begin running the animations once more..
            
            self.speed = 1
            
            // Remove all of the children nodes from the game (all of the pipes created at random by the timer.
            
            self.removeAllChildren()
            
            // Reset the game by calling the setupGame method..
            
            setupGame()
        
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
