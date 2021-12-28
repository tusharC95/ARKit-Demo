//
//  ARkitDemoVC.swift
//  ARKitDemo
//
//  Created by Tushar Chitnavis on 27/12/21.
//

import UIKit
import ARKit
import VideoToolbox

class ARkitDemoVC: UIViewController {
    
    @IBOutlet weak var faceView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var btnMesh: UISwitch!
    
    var isShowMesh = Bool()
    var faceRect = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faceView.delegate = self
        statusLabel.isHidden = true
        faceRect.frame = faceView.frame
        isShowMesh = false
        guard ARFaceTrackingConfiguration.isSupported else {
            statusLabel.isHidden = false
            statusLabel.text = "AR Face Detection is not supported on this device"
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let confguration = ARFaceTrackingConfiguration()
        faceView.session.run(confguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        faceView.session.pause()
    }
    
    @IBAction func showMesh(_ sender: Any) {
        DispatchQueue.main.async {
            self.isShowMesh = self.btnMesh.isOn
        }
        
    }
    
    func createPathFromPoints (points: [CGPoint]) -> UIBezierPath{
        
        let bezierPath = UIBezierPath()
        if points.count > 0 {
            bezierPath.move(to: points.first!)
        }
        for (i, point) in points.enumerated() {
            if i < points.endIndex {
                bezierPath.addLine(to: point)
            }
        }
        
        bezierPath.close()
        return bezierPath
    }
    
    func drawOutline (bezierPath: UIBezierPath, color: UIColor) {
        let roiPath = CAShapeLayer()
        roiPath.strokeColor = color.cgColor
        roiPath.lineWidth = 2.0
        roiPath.path = bezierPath.cgPath
        roiPath.fillColor = UIColor.clear.cgColor
        faceView?.layer.addSublayer(roiPath)
    }
}

