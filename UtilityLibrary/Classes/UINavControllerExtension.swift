//
//  UINavControllerExtension.swift
//  Deserve
//
//  Created by Swapnil Jadhav on 14/09/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation

// To fix the issue of "UINavigationController Interactive Pop Gesture Not Working"
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
