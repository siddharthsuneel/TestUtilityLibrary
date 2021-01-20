//
//  UIViewExtensions.swift
//  Deserve
//
//  Created by Shrishty Chandra on 29/01/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    enum RotationType {
        case top
        case down
    }
    struct RotationConstants {
        static let twoSeventyDegrees: CGFloat = CGFloat((Double.pi/2) * 3)
        static let ninetyDegrees: CGFloat = CGFloat(Double.pi/2)
    }

    func rotate(_ rotationType: RotationType) {
        switch rotationType {
        case .top:
            transform = CGAffineTransform(rotationAngle: RotationConstants.twoSeventyDegrees)
        case .down:
            transform = CGAffineTransform(rotationAngle: RotationConstants.ninetyDegrees)
        }

    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
       let path = UIBezierPath(
        roundedRect: bounds,
        byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius))
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       layer.mask = mask
    }

    func applyZigZagEffectAtBottom(color: UIColor) {
        let width = frame.size.width
        let height = frame.size.height

        let givenFrame = frame
        let zigZagWidth = CGFloat(8)
        let zigZagHeight = CGFloat(4)
        let yInitial = height - zigZagHeight

        let zigZagPath = UIBezierPath(rect: givenFrame)
        zigZagPath.move(to: CGPoint(x: 0, y: 0))
        zigZagPath.addLine(to: CGPoint(x: 0, y: yInitial))

        var slope = 1
        var pointX = CGFloat(0)
        var index = 0
        while pointX < width {
            pointX = zigZagWidth * CGFloat(index)
            let distance = zigZagHeight * CGFloat(slope)
            let pointY = yInitial + distance
            let point = CGPoint(x: pointX, y: pointY)
            zigZagPath.addLine(to: point)
            slope *= (-1)
            index += 1
        }

        zigZagPath.addLine(to: CGPoint(x: width, y: 0))
        zigZagPath.close()

        let shapeLayer = CAShapeLayer(layer: layer)
        backgroundColor = UIColor.clear
        shapeLayer.path = zigZagPath.cgPath
        shapeLayer.frame = bounds
        shapeLayer.fillColor = color.cgColor
        shapeLayer.masksToBounds = true
        layer.addSublayer(shapeLayer)
    }

    func applyZigZagEffectAtTop(color: UIColor) {
        let width = frame.size.width
        let givenFrame = frame
        let zigZagWidth = CGFloat(8)
        let zigZagHeight = CGFloat(4)
        let yInitial = zigZagHeight
        let zigZagPath = UIBezierPath(rect: givenFrame)

        var slope = 1
        var pointX = CGFloat(0)
        var index = 0

        while pointX < width {
            pointX = (zigZagWidth * CGFloat(index))
            let slopeHeight = zigZagHeight * CGFloat(slope)
            let pointY = yInitial + slopeHeight
            let point = CGPoint(x: pointX, y: pointY)
            zigZagPath.addLine(to: point)
            slope *= -1
            index += 1
        }

        zigZagPath.addLine(to: CGPoint(x: width, y: zigZagHeight*2))
        zigZagPath.addLine(to: CGPoint(x: 0, y: zigZagHeight*2))

        zigZagPath.close()
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.path = zigZagPath.cgPath
        shapeLayer.strokeColor =  color.cgColor
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: zigZagHeight * 2)
        shapeLayer.fillColor = color.cgColor
        shapeLayer.masksToBounds = true
        layer.addSublayer(shapeLayer)
    }

    // MARK: - Rounded Corner Methods
    func applyCorner(radius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
        layer.masksToBounds = true
    }

    func resetCornerRadiusToNone() {
        clipsToBounds = true
        layer.cornerRadius = 0
        layer.maskedCorners = []
        layer.masksToBounds = true
    }
}
