//
//  Scene.swift
//  Sightspotter
//
//  Created by Matthew Jacome on 7/6/17.
//  Copyright © 2017 matthew. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    // MARK: - Properties
    let remainingLabel = SKLabelNode()
    var timer: Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            remainingLabel.text = "Remaining: \(targetCount)"
        }
    }
    // MARK: - Functions
    func createTarget() {
        // Create targets
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        // find the scene view we are drawing into
        guard let sceneView = self.view as? ARSKView else { return }
        
        // get access to a random number generator
        let random = GKRandomSource.sharedRandom()
        
        // create a random X rotation
        let xRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 1, 0, 0))
        
        // create a random Y rotation
        let yRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 0, 1, 0))
        
        // combine them together
        let rotation = simd_mul(xRotation, yRotation)
        
        // move forward 1.5 meters into the screen
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        // combinee that with our rotation
        let transform = simd_mul(rotation, translation)
        
        // create an anchor at the finished position
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    override func didMove(to view: SKView) {
        // Hud
        remainingLabel.fontSize = 36
        remainingLabel.fontName = "AmericanTypewriter"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY - 50)
        addChild(remainingLabel)
        targetCount = 0
        
        // Timer
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {_ in
            self.createTarget()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
