//
//  TVSlideUpAnimExtension.swift
//  Deserve
//
//  Created by Swapnil Jadhav on 19/02/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import UIKit

// MARK: - TVCustomAnimProtocol
protocol TVCustomAnimProtocol: class {
    var pendingTVDataUpdates: Bool { get set }
    var isTVCustomAnimInProgress: Bool { get set }
    func animWillBegin(_ tableView: UITableView)
    func animDidComplete(_ tableView: UITableView)
}

extension TVCustomAnimProtocol {
    func animWillBegin(_ tableView: UITableView) {
        isTVCustomAnimInProgress = true
        tableView.isScrollEnabled = false
    }

    func animDidComplete(_ tableView: UITableView) {
        isTVCustomAnimInProgress = false
        tableView.isScrollEnabled = true
        if pendingTVDataUpdates {
            tableView.reloadData()
            pendingTVDataUpdates = false
        }
    }
}

// MARK: Header and cell reloading animation
extension UITableView {

    // MARK: - Public

    struct SlideUpAnimationConfig {
        var initialY: CGFloat
        var duration: TimeInterval
        var damping: CGFloat
        var delayOffset: Double
        var intialSlideDownDuration: TimeInterval = 0 // Keep 0 for "no" initial slide down animation.
        var animateInitalSlideDown: Bool {
            return intialSlideDownDuration > 0
        }
        weak var customAnimDelegate: TVCustomAnimProtocol?
    }

    func reloadRows(
        at indexPaths: [IndexPath],
        with animation: UITableView.RowAnimation,
        delay: TimeInterval = 0.3,
        completion: @escaping () -> Void) {
        reloadRows(at: indexPaths, with: animation)
        Util.dispatchAsyncAfter(delay) {
            completion()
        }
    }

    // Animate all the visible headers and cells with optionally reload TV.
    func slideUpAnimate(
        _ delegate: TVCustomAnimProtocol,
        shouldReloadData: Bool,
        slideUpAnimConfig: SlideUpAnimationConfig? = nil,
        animCompletion: EmptyClosure? = nil) {

        // Configure animation.
        var animConfig = slideUpAnimConfig ?? defaultSildeDownUpAnimConfig
        animConfig.customAnimDelegate = delegate

        animConfig.customAnimDelegate?.animWillBegin(self)

        let slideUpAnim = { [weak self] in
            guard
                let strongSelf = self,
                let indexPaths = strongSelf.indexPathsForVisibleRows
                else {
                    return
            }
            strongSelf.beginSlideUpAnimFlow(indexPaths, animConfig: animConfig, completion: animCompletion)
            return
        }

        guard shouldReloadData else {
            slideUpAnim()
            return
        }

        reloadData {
            slideUpAnim()
        }
    }

    // Reload with animate-on/off
    func slideUpReloadData(
        _ delegate: TVCustomAnimProtocol,
        animated: Bool,
        slideUpAnimConfig: SlideUpAnimationConfig? = nil,
        animCompletion: EmptyClosure? = nil) {
        guard animated else {
            reloadData()
            return
        }

        slideUpAnimate(
            delegate,
            shouldReloadData: true,
            slideUpAnimConfig: slideUpAnimConfig,
            animCompletion: animCompletion)
    }

    // Section(s) reload.
    func slideUpReloadSectionsData(
        delegate: TVCustomAnimProtocol,
        sections: [Int],
        animated: Bool,
        slideUpAnimConfig: SlideUpAnimationConfig? = nil,
        animCompletion: EmptyClosure? = nil) {
        let sectionIndexSet = IndexSet(sections)
        guard animated else {
            reloadSections(sectionIndexSet, with: UITableView.RowAnimation.none)
            return
        }
        let indexPathOrderedSet = NSOrderedSet(array: sections)

        // Configure animation.
        var animConfig = slideUpAnimConfig ?? defaultSildeDownUpAnimConfig
        animConfig.intialSlideDownDuration = 0.25
        animConfig.customAnimDelegate = delegate

        animConfig.customAnimDelegate?.animWillBegin(self)
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.reloadSections(sectionIndexSet, with: UITableView.RowAnimation.none)
            }, completion: { [weak self] _ in
                guard
                    let strongSelf = self,
                    let allVisibleIndexPaths = strongSelf.indexPathsForVisibleRows else {
                        return
                }

                var elligibleSectionIndexPaths: [IndexPath] = []
                for indexPath in allVisibleIndexPaths {
                    guard indexPathOrderedSet.contains(indexPath.section) else {
                        continue
                    }
                    elligibleSectionIndexPaths.append(indexPath)
                }

                strongSelf.beginSlideUpAnimFlow(
                    elligibleSectionIndexPaths,
                    animConfig: animConfig,
                    completion: animCompletion)
        })
    }

    // MARK: - Private

    private class FillerView: UIView {
        static let fillGapViewTag = Int.min
        private var originalClipsToBoundsValue = true
        var bottomCornerRadius: CGFloat? {
            didSet {
                guard let bottomCornerRadius = bottomCornerRadius else {
                    resetCornerRadiusToNone()
                    return
                }
                applyCorner(radius: bottomCornerRadius, maskedCorners: TVCellConstants.bottomCorners)
            }
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        required init(_ bgColor: UIColor, frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = bgColor
            tag = FillerView.fillGapViewTag
        }

        func addOnView(_ parentView: UIView) {
            originalClipsToBoundsValue = parentView.clipsToBounds
            parentView.clipsToBounds = false
            parentView.insertSubview(self, at: 0)
        }

        override func removeFromSuperview() {
            if let parentView = superview {
                parentView.clipsToBounds = originalClipsToBoundsValue
            }
            super.removeFromSuperview()
        }
    }

    var defaultSildeDownUpAnimConfig: SlideUpAnimationConfig {
        return SlideUpAnimationConfig(
            initialY: bounds.size.height/12,
            duration: 1,
            damping: 0.7,
            delayOffset: 0.05)
    }

    // MARK: Private Methods
    private func beginSlideUpAnimFlow(
        _ indexPaths: [IndexPath],
        animConfig: SlideUpAnimationConfig,
        completion: EmptyClosure? = nil) {

        let visibleHeadersAndCells = setupBeforeSlideUpAnimation(indexPaths)
        // print("swap *** visibleHeadersAndCells \(visibleHeadersAndCells.count)")
        slideDownHeadersAndCells(
            for: visibleHeadersAndCells,
            animConfig: animConfig,
            completion: { [weak self] in
                self?.slideUpHeadersAndCells(
                    visibleHeadersAndCells: visibleHeadersAndCells,
                    config: animConfig,
                    completion: completion)
        })

    }

    private func setupBeforeSlideUpAnimation(_ indexPaths: [IndexPath]) -> [UIView] {
        var visibleHeadersAndCells: [UIView] = []
        var currentSection = -1
        for indexPath in indexPaths {
            // Header if applicable
            if currentSection < indexPath.section {
                currentSection = indexPath.section
                if let header = headerView(forSection: currentSection) {
                    visibleHeadersAndCells.append(header)
                    UITableView.addGapFillerView(header, shouldApplyBottomRoundedCorner: false)
                }
            }

            // Cell
            if let cell = cellForRow(at: indexPath) {
                visibleHeadersAndCells.append(cell)
                let rowsCount = numberOfRows(inSection: indexPath.section)
                let isLastCellInSection = indexPath.row == (rowsCount - 1)
                let isSecondLastCellInSection = indexPath.row == (rowsCount - 2)
                if isLastCellInSection {
                    /**
                     // Add Footer if present.
                     // NOTE: Usually slideup animation with footer will look good only
                     // if footer's look is similar to the last TVCell and last TVCell doesn't have rouded corner.
                     // OTHERWISE CONSIDER ADDING FOOTER AS PART OF LAST TVCELL ONLY,
                     // so that slideUp animation would look good.

                     // When footer support is required below code can be used.
                     if let footer = footerView(forSection: indexPath.section) {
                         // Need to add gap filler view so that gap will not be visible between last TVCell and footer.
                         UITableView.addGapFillerView(
                             cell,
                             shouldApplyBottomRoundedCorner: isSecondLastCellInSection)
                         visibleHeadersAndCells.append(footer)
                     }
                     */
                } else {
                    UITableView.addGapFillerView(cell, shouldApplyBottomRoundedCorner: isSecondLastCellInSection)
                }
            }
        }
        return visibleHeadersAndCells
    }

    private func slideDownHeadersAndCells(
        for visibleHeadersAndCells: [UIView],
        animConfig: SlideUpAnimationConfig,
        completion: @escaping EmptyClosure) {
        let animate = animConfig.animateInitalSlideDown
        for visibleView in visibleHeadersAndCells {
            bringSubviewToFront(visibleView)
            if !animate {
                visibleView.transform = CGAffineTransform(translationX: 0, y: animConfig.initialY)
            }
        }

        guard animate else {
            completion()
            return
        }

        UIView.animate(
            withDuration: animConfig.intialSlideDownDuration,
            animations: {
                visibleHeadersAndCells.forEach { (view) in
                    view.transform = CGAffineTransform(translationX: 0, y: animConfig.initialY)
                }
        },
            completion: { (_) in
                completion()
        })
    }

    private func slideUpHeadersAndCells(
        visibleHeadersAndCells: [UIView],
        config: SlideUpAnimationConfig,
        completion: EmptyClosure?) {
        var animationInProgressCount = visibleHeadersAndCells.count
        for (index, view) in visibleHeadersAndCells.enumerated() {
            let gapFillerView = view.viewWithTag(FillerView.fillGapViewTag)
            UIView.animate(
                withDuration: config.duration,
                delay: config.delayOffset * Double(index),
                usingSpringWithDamping: config.damping,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    view.transform = CGAffineTransform.identity
            },
                completion: { [weak self] (_) in
                    gapFillerView?.removeFromSuperview()
                    animationInProgressCount -= 1
                    if animationInProgressCount == 0 {
                        completion?()
                        if let strongSelf = self {
                            config.customAnimDelegate?.animDidComplete(strongSelf)
                        }
                    }
            })
        }
    }

    @discardableResult
    private static func addGapFillerView(_ toView: UIView, shouldApplyBottomRoundedCorner: Bool) -> UIView {
        func bgColor() -> UIColor {
            let defaultColor = UIColor.white
            var bgColor = toView.backgroundColor ?? defaultColor
            if let cell = toView as? UITableViewCell,
                let color = cell.contentView.backgroundColor,
                color != .clear {
                bgColor = color
            }
            return bgColor
        }

        let heightOffset: CGFloat = 0.9
        let size = CGSize(width: toView.bounds.size.width, height: toView.bounds.size.height)
        let fillViewFrame = CGRect(x: 0, y: size.height-1, width: size.width, height: size.height * heightOffset)
        let fillerView = FillerView(bgColor(), frame: fillViewFrame)
        if shouldApplyBottomRoundedCorner {
            fillerView.bottomCornerRadius = TVCellConstants.cornerRadius
        }
        fillerView.addOnView(toView)
        return fillerView
    }
}
