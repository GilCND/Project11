//
//  GameScene.swift
//  Project11
//
//  Created by Felipe Gil on 2021-06-24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ballsLabel: SKLabelNode!
    var ballCounter = 5  {
        didSet {
            ballsLabel.text = "Balls: \(ballCounter)"
        }
    }
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls : 5"
        ballsLabel.position = CGPoint(x: 480, y: 700)
        addChild(ballsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box  = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "boxes"
                addChild(box)
                
            } else {
                var ballArray = ["ballRed", "ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballYellow"]
                ballArray.shuffle()
                
                let ball = SKSpriteNode(imageNamed: ballArray[0])
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = location
                ball.position.y = 720
                ball.name = "ball"
                if ballCounter == 0 {
                    
                } else {
                    addChild(ball)
                    ballCounter -= 1
                }
            }
        }
    }
    
    private func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    private func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase: SKSpriteNode = isGood ? SKSpriteNode(imageNamed: "slotBaseGood") : SKSpriteNode(imageNamed: "slotBaseBad")
        slotBase.name = isGood ? "good" : "bad"
        let slotGlow: SKSpriteNode = isGood ? slotGlow = SKSpriteNode(imageNamed: "slotGlowGood") : SKSpriteNode(imageNamed: "slotGlowBad")
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func colision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(object: ball)
            score += 1
            ballCounter += 1
        } else if object.name == "bad" {
            destroy(object: ball)
            score -= 1
        } else if object.name == "boxes"{
            destroy(object: object)
        }
    }
    
    func destroy(object: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = object.position
            addChild(fireParticles)
        }
        object.removeFromParent()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        if contact.bodyA.node?.name == "ball" {
            colision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            colision(between: nodeB, object: nodeA)
            
        }
    }
}
