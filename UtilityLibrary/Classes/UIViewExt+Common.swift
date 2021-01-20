//
//  UIViewExt+Common.swift
//  Deserve
//
//  Created by Amit Bobade on 31/12/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import UIKit

extension UIView {
    func bindFrameToSuperviewBounds() {
        guard let superview = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }

    func nibSetup(name: String) {
        guard let view = UINib.instanceFromNib(
            name,
            owner: self) else { return }
        frame = bounds
        view.frame = bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}
