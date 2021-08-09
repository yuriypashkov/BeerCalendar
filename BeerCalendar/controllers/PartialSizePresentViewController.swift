//
//  PartialSizePresentViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/9/21.
//

import Foundation
import UIKit

class PartialSizePresentViewController: UIPresentationController {
    
    let heightRatio : CGFloat
       
       init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, withRatio ratio: Float = 0.5) {
           heightRatio = CGFloat(ratio)
           super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
       }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let cv = containerView else { fatalError("No container view available") }
        return CGRect(x: 0, y: cv.bounds.height * (1 - heightRatio), width: cv.bounds.width, height: cv.bounds.height * heightRatio)
    }
    
    override func presentationTransitionWillBegin() {
            
            let bdView = UIView(frame: containerView!.bounds)
            bdView.backgroundColor = .black.withAlphaComponent(0.3)
            containerView?.addSubview(bdView)
            bdView.addSubview(presentedView!)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            bdView.addGestureRecognizer(tapGesture)
            
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    
}
