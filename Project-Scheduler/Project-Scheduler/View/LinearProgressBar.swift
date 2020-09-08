//
//  LinearProgressBar.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation
import UIKit

class LinearProgressBar: UIView {

    @IBInspectable public var backCircleColor: UIColor = UIColor.lightGray
    @IBInspectable public var startGradientColor: UIColor = UIColor.red
    @IBInspectable public var endGradientColor: UIColor = UIColor.orange
    
    private var backgroundLayer: CAShapeLayer!
    private var foregroundLayer: CAShapeLayer!
    private var gradientLayer: CAGradientLayer!
    
    public var progress: CGFloat = 0 {
        didSet {
            didProgressUpdated()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard layer.sublayers == nil else {
            return
        }
        
        let width = rect.width
        let height = rect.height
        let lineWidth = 0.8 * min(width, height)
        
        //Set linear slider height and width both background
        backgroundLayer = createBar(rect: rect, strokeColor: backCircleColor.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        //Set linear slider height and width both foreground
        foregroundLayer = createBar(rect: rect, strokeColor: UIColor.red.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        
        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = rect
        gradientLayer.mask = foregroundLayer
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
    }
    
    private func createBar(rect: CGRect, strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        
        let circularPath = UIBezierPath()
        circularPath.move(to: CGPoint(x: 0, y: 10))
        circularPath.addLine(to: CGPoint(x: width, y: 10))
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = fillColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        
        
        return shapeLayer
    }
    
    private func didProgressUpdated() {
        foregroundLayer?.strokeEnd = progress
        gradientLayer?.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
    }
    
}
