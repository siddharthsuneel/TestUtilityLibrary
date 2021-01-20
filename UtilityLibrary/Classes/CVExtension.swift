//
//  CVExtension.swift
//  Deserve
//
//  Created by Swapnil Jadhav on 07/05/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reusableIdentifier)
    }

    func reloadData(with completion: @escaping EmptyClosure) {
        UIView.animate(
            withDuration: 0,
            animations: {
                self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
}
