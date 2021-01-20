//
//  UITableViewExtension.swift
//  Deserve
//
//  Created by Swapnil Jadhav on 10/02/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: Scrolling related
extension UITableView {
    // swiftlint:disable identifier_name
    func scroll(to: ScrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            guard self.numberOfSections > 0 else { return }
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            guard numberOfRows > 0 else { return }
            switch to {
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    // swiftlint:enable identifier_name

    enum ScrollsTo {
        case top, bottom
    }

    // MARK: Register / other related
    func register<T: UITableViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.reusableIdentifier)
    }

    func registerHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: T.reusableIdentifier)
    }

    func centerContentForTableView() {
        let contentSize = self.contentSize
        let boundsSize = bounds.size

        if contentSize.height < boundsSize.height {
            let yOffset = floor(boundsSize.height - contentSize.height) / 2
            contentOffset = CGPoint(x: 0.0, y: -yOffset)
        }
    }

    func reloadData(with completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0,
            animations: {
                self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
}

extension UITableViewCell {
    static var reusableIdentifier: String {
        return String(describing: self)
    }

    static var nibName: String {
        return String(describing: self)
    }

    func centerPosition(_ component: UIView) -> CGFloat {
        let centerWidth = contentView.frame.size.width/2
        return centerWidth - component.frame.size.width/2
    }

    func circularCorner(radius: CGFloat, maskedCorners: CACornerMask, onCell: Bool = false) {
        if onCell {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = maskedCorners
            layer.masksToBounds = true
        } else {
            contentView.clipsToBounds = true
            contentView.layer.cornerRadius = radius
            contentView.layer.maskedCorners = maskedCorners
            contentView.layer.masksToBounds = true
        }
    }
}
