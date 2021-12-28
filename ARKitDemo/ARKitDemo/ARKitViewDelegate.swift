//
//  ARKitViewDelegate.swift
//  ARKitDemo
//
//  Created by Tushar Chitnavis on 28/12/21.
//

import UIKit
import ARKit
import VideoToolbox

extension ARkitDemoVC: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = faceView.device else {
            return nil
        }
        
        let faceGeomerty = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeomerty)
        
        //NOTE:- UNCOMMENT TO NUMBER EACH POINT ON FACE
        //        var facePoints = [Int]()
        //
        //        if !isShowMesh {
        //            faceNode.geometry?.firstMaterial?.transparency = 0.0
        //            facePoints = createFeatureArray()
        //        }
        //        else{
        //            faceNode.geometry?.firstMaterial?.transparency = 1.0
        //            facePoints = Array(0..<1220)
        //        }
        
        //        for x in facePoints
        //         {
        //            let text = SCNText(string: "\(x)", extrusionDepth: 0)
        //            let txtnode = SCNNode(geometry: text)
        //            txtnode.scale = SCNVector3(x: 0.0002, y: 0.0002, z: 0.0002)
        //            txtnode.name = "\(x)"
        //            faceNode.addChildNode(txtnode)
        //            txtnode.geometry?.firstMaterial?.fillMode = .fill
        //        }
        //
        
        faceNode.geometry?.firstMaterial?.fillMode = .lines
        
        return faceNode
    }
    
    func renderer(
        _ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                      return
                  }
            
            var pointsOnDevice = [CGPoint]()
            pointsOnDevice.removeAll()
            
            var pointsOnImage = [CGPoint]()
            pointsOnImage.removeAll()
            
            let faceNode = SCNNode(geometry: faceGeometry)
            faceNode.geometry?.firstMaterial?.fillMode = .lines
            
            //NOTE:- UNCOMMENT TO NUMBER EACH POINT ON FACE
            //            var facePoints = [Int]()
            
            if !isShowMesh {
                faceNode.geometry?.firstMaterial?.transparency = 0.0
                
                var faceFeaturesPoints = [Int]()
                
                let eyeTopLeft = Array(1090...1101)
                let eyeBottomLeft = Array(1102...1108) + Array(1085...1089)
                let eyeTopRight = Array(1069...1080)
                let eyeBottomRight = Array(1081...1084) + Array(1061...1068)
                
                let facePointsLeftEye = eyeTopLeft + eyeBottomLeft
                faceFeaturesPoints.append(contentsOf: facePointsLeftEye)
                
                let facePointsRightRight = eyeTopRight + eyeBottomRight
                faceFeaturesPoints.append(contentsOf: facePointsRightRight)
                
                
                let mouthTopLeft = Array(250...256)
                let mouthTopCenter = [24]
                let mouthTopRight = Array(685...691).reversed()
                let mouthRight = [684]
                let mouthBottomRight = [682,683,710,725,709,700]
                let mouthBottomCenter = [25]
                let mouthBottomLeft = [265,274,290,275,247,248]
                let mouthLeft = [249]
                let mouthClockwise : [Int] = mouthLeft +
                mouthTopLeft + mouthTopCenter +
                mouthTopRight + mouthRight +
                mouthBottomRight + mouthBottomCenter +
                mouthBottomLeft
                
                faceFeaturesPoints.append(contentsOf: mouthClockwise)
                
                
                for x in faceFeaturesPoints {
                    
                    //NOTE:- UNCOMMENT TO NUMBER EACH POINT ON FACE
                    //                    let child = node.childNode(withName: "\(x)", recursively: false)
                    //                    child?.position = SCNVector3(faceAnchor.geometry.vertices[x])
                    
                    DispatchQueue.main.async {
                        let point = faceAnchor.verticeAndProjection(to: self.faceView, facePoint: x)
                        pointsOnDevice.append(point)
                    }
                }
                
                DispatchQueue.main.async {
                    
                    var faceFeaturesCoordinates = [[CGPoint]]()
                    faceFeaturesCoordinates.append(Array(pointsOnDevice[0...(facePointsLeftEye.count - 1)]))
                    faceFeaturesCoordinates.append(Array(pointsOnDevice[(facePointsLeftEye.count)...(facePointsLeftEye.count + facePointsRightRight.count - 1)]))
                    faceFeaturesCoordinates.append(Array(pointsOnDevice[(facePointsLeftEye.count + facePointsRightRight.count)...(faceFeaturesPoints.count - 1)]))
                    
                    self.faceView.clearLayers()
                    
                    for featurePath in faceFeaturesCoordinates {
                        self.drawROIPointsOnFace(points: featurePath)
                    }
                    
                }
                
            }
            else{
                faceNode.geometry?.firstMaterial?.transparency = 1.0
                
                //NOTE:- UNCOMMENT TO NUMBER EACH POINT ON FACE
                //                facePoints = Array(0..<1220)
                //                for x in  facePoints {
                //                    let child = node.childNode(withName: "\(x)", recursively: false)
                //                    child?.position = SCNVector3(faceAnchor.geometry.vertices[x])
                //                }
                
                DispatchQueue.main.async {
                    self.faceView.clearLayers()
                }
                
            }
            faceGeometry.update(from: faceAnchor.geometry)
        }
    
    func drawROIPointsOnFace(points: [CGPoint]) {
        let bezierPath = self.createPathFromPoints(points: points)
        self.drawOutline(bezierPath: bezierPath, color: .green)
        
    }
}
