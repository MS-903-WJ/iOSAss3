//
//  SlideUpPresentationController.swift
//  iOSAss3
//
//  Created by John Wang on 11/5/2023.
//

import UIKit

class SlideUpPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let size = CGSize(width: containerView.bounds.width, height: containerView.bounds.height * 0.6)
        let origin = CGPoint(x: 0, y: containerView.bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }
}
