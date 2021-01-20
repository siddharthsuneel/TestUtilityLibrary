//
//  UIViewExt+Shimmer.swift
//  Deserve
//
//  Created by Siddharth Suneel on 24/12/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import ShimmerSwift

extension UIView {
    func addShimmerView(
        _ shimmerViewFrame: CGRect,
        backgroundColor: UIColor = RootColorTheme.sectionColor,
        shimmerOpacity: CGFloat = ShimmerViewConstants.shimmerOpacity,
        shimmerAnimOpacity: CGFloat = ShimmerViewConstants.shimmerAnimOpacity,
        shimmerSpeed: CGFloat = ShimmerViewConstants.shimmerSpeed,
        highlightLength: CGFloat = ShimmerViewConstants.shimmerHighlightLength) -> ShimmeringView {
        let shimmerView = ShimmeringView(
            frame: shimmerViewFrame)
        addSubview(shimmerView)
        let shimmerContentView = UIView(frame: shimmerView.frame)
        shimmerContentView.backgroundColor = backgroundColor
        shimmerView.contentView = shimmerContentView
        shimmerView.isShimmering = true
        shimmerView.shimmerSpeed = shimmerSpeed
        shimmerView.shimmerPauseDuration = ShimmerViewConstants.shimmerPauseDuration
        shimmerView.shimmerAnimationOpacity = shimmerAnimOpacity
        shimmerView.shimmerOpacity = shimmerOpacity
        shimmerView.shimmerHighlightLength = highlightLength
        bringSubviewToFront(shimmerView)
        return shimmerView
    }
}

extension ShimmeringView {
    func removeShimmerFromSuperView() {
        isShimmering = false
        removeFromSuperview()
    }
}
