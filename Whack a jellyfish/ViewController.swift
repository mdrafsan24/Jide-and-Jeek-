//
//  ViewController.swift
//  Whack a jellyfish
//
//  Created by Rafsan Chowdhury on 11/21/17.
//  Copyright © 2017 appimas24. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {
    
    var countTimer = Each(1).seconds // this timer will keep counting up by one second
    var countDown = 10

    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playBtn: UIButton!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    @IBAction func play(_ sender: Any) {
        self.setTimer()
        self.addNode()
        self.playBtn.isEnabled = false
    }
    @IBAction func reset(_ sender: Any) {
        self.countTimer.stop()
        self.restoreTimer()
        self.playBtn.isEnabled = true
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: "JellyFish", recursively: false)
        jellyfishNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),randomNumbers(firstNum: -0.5, secondNum: 0.5),randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyfishNode!)
//        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
//        node.position = SCNVector3(0,0,-1)
//        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as? SCNView
        // Where user tapped on sceneview
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        // Hit test sees if the coordinate you touched corresponds to an object inside sceneview (in our case its the box)
        let hitTest = sceneViewTappedOn?.hitTest(touchCoordinates, options: nil)
        if (hitTest?.isEmpty)! {
            print("Didn't touch anything")
        } else {
            if countDown > 0 {
                let results = hitTest?.first!
                let node = results?.node
                // TO not animate while already animated
                if (node?.animationKeys.isEmpty)! {
                    // Scenetransaction -
                    SCNTransaction.begin()
                    self.animateNode(node: node!)
                    SCNTransaction.completionBlock = {
                        node?.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
            //let geometry = results?.node.geometry
            //print(geometry)
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,node.presentation.position.y - 0.2,node.presentation.position.z - 0.2) // Relative to the world origin
        spin.duration = 0.1
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "postion")
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.countTimer.perform { () -> NextStep in
            self.countDown -= 1
            self.timer.text = String(self.countDown)
            if self.countDown == 0 {
                self.timer.text = "You lost!"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countDown = 10
        self.timer.text = String(self.countDown)
    }
}
