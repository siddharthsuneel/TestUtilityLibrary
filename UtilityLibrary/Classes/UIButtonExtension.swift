//
//  UIButtonExtension.swift
//  Deserve
//
//  Created by Amit Bobade on 27/02/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    struct CloseButtonConstants {
        static let closeButtonTop: CGFloat = 29.0
        static let closeButtonTrailing: CGFloat = 62.0
        static let closeButtonWidth: CGFloat = 48.0
        static let closeButtonHeight: CGFloat = 64.0
        static let closeButtonLeftInsets: CGFloat = 16.0
        static let closeButtonTopInsets: CGFloat = 3.0
        static let closeButtonShadowOpacity: Float = 0.6
        static let closeButtonShadowRadius: CGFloat = 12
        static let closeButtonShadowOffset = CGSize(width: 0, height: 0)
        static let closeButtonImageName = "close"
        static let closeButtonTransparentImageName = "closeTrans"
        #if APPCLIP
        static let closeButtonShadowColor = UIColor.rgbColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        #else
        static let closeButtonShadowColor = ColorConst.black35
        #endif
    }

    struct DownArrowButtonConstants {
        static let downArrowButtonWidth: CGFloat = 40.0
        static let downArrowButtonHeight: CGFloat = 40.0
        static let downArrowButtonTop: CGFloat = 40.0
        static let downArrowButtonTrailing: CGFloat = 27.0
        static let downArrowButtonImageName = "downArrow"
        static let downArrowBlackButtonImageName = "downArrowBlack"
    }

    class func closeButton(
        _ viewWidth: CGFloat,
        selector: Selector,
        target: Any,
        imageName: String = CloseButtonConstants.closeButtonImageName) -> UIButton {
        let closeButton = UIButton(type: .custom)

        closeButton.frame = CGRect(
            x: viewWidth - CloseButtonConstants.closeButtonTrailing,
            y: CloseButtonConstants.closeButtonTop,
            width: CloseButtonConstants.closeButtonWidth,
            height: CloseButtonConstants.closeButtonHeight)

        closeButton.setImage(
            UIImage(named: imageName),
            for: UIControl.State.normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(
            top: closeButton.contentEdgeInsets.top + CloseButtonConstants.closeButtonTopInsets,
            left: closeButton.contentEdgeInsets.left + CloseButtonConstants.closeButtonLeftInsets,
            bottom: closeButton.contentEdgeInsets.bottom,
            right: closeButton.contentEdgeInsets.right)

        closeButton.layer.shadowOpacity = CloseButtonConstants.closeButtonShadowOpacity
        closeButton.layer.shadowOffset = CloseButtonConstants.closeButtonShadowOffset
        closeButton.layer.shadowRadius = CloseButtonConstants.closeButtonShadowRadius
        closeButton.layer.shadowColor = CloseButtonConstants.closeButtonShadowColor.cgColor

        closeButton.addTarget(
            target,
            action: selector,
            for: UIControl.Event.touchUpInside)
        return closeButton
    }

    class func downArrowButton(
        _ viewWidth: CGFloat,
        selector: Selector,
        target: Any,
        imageName: String = DownArrowButtonConstants.downArrowButtonImageName,
        buttonTop: CGFloat = DownArrowButtonConstants.downArrowButtonTop,
        buttonTrailing: CGFloat = DownArrowButtonConstants.downArrowButtonTrailing,
        buttonWidth: CGFloat = DownArrowButtonConstants.downArrowButtonWidth,
        buttonHeight: CGFloat = DownArrowButtonConstants.downArrowButtonHeight) -> UIButton {
        let downArrowButton = UIButton(type: .custom)

        downArrowButton.frame = CGRect(
            x: viewWidth - (buttonTrailing + buttonWidth),
            y: buttonTop,
            width: buttonWidth,
            height: buttonHeight)

        downArrowButton.setImage(
            UIImage(named: imageName),
            for: UIControl.State.normal)

        downArrowButton.layer.shadowOpacity = CloseButtonConstants.closeButtonShadowOpacity
        downArrowButton.layer.shadowOffset = CloseButtonConstants.closeButtonShadowOffset
        downArrowButton.layer.shadowRadius = CloseButtonConstants.closeButtonShadowRadius
        downArrowButton.layer.shadowColor = CloseButtonConstants.closeButtonShadowColor.cgColor

        downArrowButton.addTarget(
            target,
            action: selector,
            for: UIControl.Event.touchUpInside)
        return downArrowButton
    }

    func setButtonImage(
        title: String,
        titleColor: UIColor,
        iconName: String,
        bgColor: UIColor) {
        backgroundColor = bgColor
        setTitle(title, for: .normal)
        setTitle(title, for: .highlighted)
        setTitleColor(titleColor, for: .normal)
        setTitleColor(titleColor, for: .highlighted)
        setImage(UIImage(named: iconName), for: .normal)
        setImage(UIImage(named: iconName), for: .highlighted)
        let inset = (titleLabel?.frame.width)! + (imageView?.frame.width)!
        imageEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)

        layoutIfNeeded()
    }
}
