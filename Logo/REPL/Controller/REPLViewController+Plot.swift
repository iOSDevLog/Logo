//
//  REPLViewController+Plot.swift
//  Logo
//
//  Created by developer on 8/27/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

extension REPLViewController {
    var panelBounds: CGRect {
        get {
            return self.panelView.bounds
        }
    }

    var panelWidth: CGFloat {
        get {
            return self.panelView.bounds.width
        }
    }

    var panelHeight: CGFloat {
        get {
            return self.panelView.bounds.height
        }
    }

    var halfPanelWidth: CGFloat {
        get {
            return self.panelWidth / 2
        }
    }

    var halfPanelHeight: CGFloat {
        get {
            return self.panelHeight / 2
        }
    }

    var panelCenter: CGPoint {
        get {
            return CGPoint(x: halfPanelWidth, y: halfPanelHeight)
        }
    }

    func addNode(_ position: CGPoint, text: String? = nil, color: UIColor = UIColor.red, radius: CGFloat = 20) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2), cornerRadius: radius).cgPath
        shapeLayer.fillColor = color.cgColor
        panelView.layer.addSublayer(shapeLayer)

        if let text = text {
            let textLayer = CATextLayer()
            textLayer.fontSize = 28
            let size = text.size(ofFont: textLayer.font as! UIFont)
            textLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            textLayer.position = position
            textLayer.string = text
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = UIColor.black.cgColor
            textLayer.contentsScale = UIScreen.main.scale
            panelView.layer.addSublayer(textLayer)
        }
    }

    func addLine(_ startPosition: CGPoint, endPosition: CGPoint) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.frame = self.panelBounds
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.blue.cgColor

        let openSquarePath = UIBezierPath()
        openSquarePath.move(to: startPosition)
        openSquarePath.addLine(to: endPosition)

        shapeLayer.path = openSquarePath.cgPath
        panelView.layer.addSublayer(shapeLayer)
    }
}

