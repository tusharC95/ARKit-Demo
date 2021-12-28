//
//  Extensions.swift
//  ARKitDemo
//
//  Created by Tushar Chitnavis on 28/12/21.
//

import Foundation
import UIKit
import ARKit
import VideoToolbox

extension UIImage {
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let validImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: validImage)
    }
}

extension ARFaceAnchor{
    // struct to store the 3d vertex and the 2d projection point
    struct VerticesAndProjection {
        var vertex: SIMD3<Float>
        var projected: CGPoint
    }
    
    // return a struct with vertices and projection
    func verticeAndProjection(to view: ARSCNView, facePoint: Int) -> CGPoint{
        
        let point = SCNVector3(geometry.vertices[facePoint])
        
        let col = SIMD4<Float>(SCNVector4())
        let pos = SIMD4<Float>(SCNVector4(point.x, point.y, point.z, 1))
        let pworld = transform * simd_float4x4(col, col, col, pos)
        let vect = view.projectPoint(SCNVector3(pworld.position.x, pworld.position.y, pworld.position.z))
        let p = CGPoint(x: CGFloat(vect.x), y: CGFloat(vect.y))
        return p
    }
}

extension matrix_float4x4 {
    
    /// Get the position of the transform matrix.
    public var position: SCNVector3 {
        get{
            return SCNVector3(self[3][0], self[3][1], self[3][2])
        }
    }
}

extension UIView{
    
    private struct drawCircleProperty{
        static let circleFillColor = UIColor.green
        static let circleStrokeColor = UIColor.black
        static let circleRadius: CGFloat = 3.0
    }
    
    func drawCircle(point: CGPoint) {
        
        let circlePath = UIBezierPath(arcCenter: point, radius: drawCircleProperty.circleRadius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 1.0), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = drawCircleProperty.circleFillColor.cgColor
        shapeLayer.strokeColor = drawCircleProperty.circleStrokeColor.cgColor
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawCircles(points: [CGPoint]){
        for point in points {
            self.drawCircle(point: point)
        }
    }
    
    func clearLayers(){
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
    }
}
