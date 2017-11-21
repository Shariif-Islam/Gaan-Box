//
//  Animation.swift
//  GaanBoxN
//
//  Created by AdBox on 6/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class Animation  {
    
    static let shared = Animation()
    
    func animateNoPreviousTrackBounce(_ layer: CALayer) {
        self.animateBounce(fromValue: NSNumber(value: 0 as Int), toValue: NSNumber(value: 25 as Int), layer: layer)
    }
    
    func animateNoNextTrackBounce(_ layer: CALayer) {
        self.animateBounce(fromValue: NSNumber(value: 0 as Int), toValue: NSNumber(value: -25 as Int), layer: layer)
    }
    
    /**
     - Animation for swipe
     */
    func animateBounce(fromValue: NSNumber, toValue: NSNumber, layer: CALayer) {
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.2
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        layer.add(animation, forKey: "Animation")
    }
    
    func animateContentChange(_ transitionSubtype: String, layer: CALayer) {
        let transition = CATransition()
        
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        transition.type = kCATransitionReveal
        transition.subtype = transitionSubtype
        
        layer.add(transition, forKey: kCATransition)
    }
    
    func animateZoomInOut(button: UIButton) {
        
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        button.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
    
    func animateTable(tableView: UITableView) {
        
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        //let tableHeight: CGFloat = tableView.bounds.size.width
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 20, y: 20)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
}
