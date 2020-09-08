//
//  CircularProgressBar.swift
//  Project-Scheduler
//
//  Created by user172177 on 5/10/20.
//  Copyright © 2020 MahelManjithaM. All rights reserved.
//

import Foundation

import UIKit

class CircularProgressBar: UIView {
    
    @IBInspectable public var backCircleColor: UIColor = UIColor.lightGray
    @IBInspectable public var startGradientColor: UIColor = UIColor.red
    @IBInspectable public var endGradientColor: UIColor = UIColor.orange
    @IBInspectable public var textColor: UIColor = UIColor.black
    @IBInspectable public var customTitle: String = ""
    @IBInspectable public var customSubtitle: String = ""
    
    private var backgroundLayer: CAShapeLayer!
    private var foregroundLayer: CAShapeLayer!
    private var titleTextLayer: CATextLayer!
    private var subTitleTextLayer: CATextLayer!
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
        
        var title = "\(Int(progress * 100))"
        var subtitle = ""
        
        if customTitle != "" {
            title = customTitle
        }
        
        if customSubtitle != "" {
            subtitle = customSubtitle
        }
        
        let width = rect.width
        let height = rect.height
        
        let lineWidth = 0.1 * min(width, height)
        
        backgroundLayer = createCircularLayer(rect: rect, strokeColor: backCircleColor.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        foregroundLayer = createCircularLayer(rect: rect, strokeColor: UIColor.red.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = rect
        gradientLayer.mask = foregroundLayer
        
        titleTextLayer = createTitle(rect: rect, text: title, textColor: textColor.cgColor)
        subTitleTextLayer = createSubTitle(rect: rect, text: subtitle, textColor: textColor.cgColor)
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(titleTextLayer)
        layer.addSublayer(subTitleTextLayer)
    }
    
    private func createCircularLayer(rect: CGRect, strokeColor: CGColor,
                                     fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        let height = rect.height
        
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = (min(width, height) - lineWidth) / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = fillColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        
        return shapeLayer
    }
    
    private func createTitle(rect: CGRect, text: String, textColor: CGColor) -> CATextLayer {
        
        let width = rect.width
        let height = rect.height
        
        let fontSize = min(width, height) / 4
        let offset = min(width, height) * 0.1
        
        let layer = CATextLayer()
        layer.string = "\(text)%"
        layer.backgroundColor = UIColor.clear.cgColor
        layer.foregroundColor = textColor
        layer.fontSize = fontSize
        layer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: fontSize + offset)
        layer.alignmentMode = .center
        
        return layer
    }
    
    private func createSubTitle(rect: CGRect, text: String, textColor: CGColor) -> CATextLayer {
        
        let width = rect.width
        let height = rect.height
        
        let fontSize = min(width, height) / 12
        let offset = min(width, height) * 0.35
        
        let layer = CATextLayer()
        layer.string = "\(text)%"
        layer.backgroundColor = UIColor.clear.cgColor
        layer.foregroundColor = textColor
        layer.fontSize = fontSize
        layer.frame = CGRect(x: 0, y: (height - fontSize + offset) / 2, width: width, height: fontSize + offset)
        layer.alignmentMode = .center
        
        return layer
    }
    
    private func didProgressUpdated() {
        var title = "\(Int(progress * 100))%"
        var subtitle = ""
        
        if customTitle != "" {
            title = customTitle
        }
        
        if customSubtitle != "" {
            subtitle = customSubtitle
        }
        
        titleTextLayer?.string = title
        subTitleTextLayer?.string = subtitle
        foregroundLayer?.strokeEnd = progress
        
        gradientLayer?.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
    }
    
}
