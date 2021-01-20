//
//  ViewToControllerProtocol.swift
//  Deserve
//
//  Created by Shrishty Chandra on 24/02/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import UIKit

protocol ViewToVCProtocol: class {
    associatedtype ViewModel
    associatedtype ViewController: VC
    typealias VCFactoryClosure = (ViewModel) -> ViewController?

    var model: ViewModel? { get set }
    var contentVCFactory: VCFactoryClosure? { get set }
    var cachedContentVC: ViewController? { get set }
    var contentVC: ViewController? { get }
    var contentView: UIView { get }

    func addContentVCToParentVC(
        parentVC: VC,
        model: ViewModel,
        contentVCFactory: VCFactoryClosure?)

    func addContentVCToParentVC(
        parentVC: VC,
        model: ViewModel,
        contentVCFactory: VCFactoryClosure?,
        contentViewFrame: CGRect?)

    func removeContentVCFromParentVC()
    func resetContentVCFactory()
}

extension ViewToVCProtocol {
    func addContentVCToParentVC(
        parentVC: VC,
        model: ViewModel,
        contentVCFactory: VCFactoryClosure?) {
        addContentVCToParentVC(
            parentVC: parentVC,
            model: model,
            contentVCFactory: contentVCFactory,
            contentViewFrame: nil)
    }

    // Does below these things:
    // 1. injects model to self view.
    // 2. get cachedContentVC. (note, cachedContentVC may be lazily initialise and reuse.
    // And also injected with latest model).
    // 3. If the contentVC is not added already then self view adds it.
    func addContentVCToParentVC(
        parentVC: VC,
        model: ViewModel,
        contentVCFactory: VCFactoryClosure?,
        contentViewFrame: CGRect?) {
        self.model = model
        self.contentVCFactory = contentVCFactory
        guard
            let contentVC = contentVC,
            contentVC.view.superview == nil
            else {
                return
        }
        parentVC.addChild(contentVC)
        contentVC.didMove(toParent: parentVC)
        contentVC.view.frame = contentViewFrame ?? contentView.frame
        contentView.addSubview(contentVC.view)
    }

    func removeContentVCFromParentVC() {
        guard let contentVC = contentVC else {
            return
        }
        contentVC.view.removeFromSuperview()
        contentVC.willMove(toParent: nil)
        contentVC.removeFromParent()
    }

    func removeCachedContentVCIfApplicable() {
        defer {
            cachedContentVC = nil
        }
        guard let cachedContentVC = cachedContentVC, cachedContentVC.view.superview != nil else {
            return
        }
        cachedContentVC.view.removeFromSuperview()
        cachedContentVC.willMove(toParent: nil)
        cachedContentVC.removeFromParent()
    }

    func resetContentVCFactory() {
        removeCachedContentVCIfApplicable()
        contentVCFactory = nil
    }
}
