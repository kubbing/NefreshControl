//
//  NefreshControl.swift
//  NefreshControl
//
//  Created by Jakub Hladik on 16/08/16.
//  Copyright © 2016 Jakub Hladik. All rights reserved.
//

import UIKit


enum NefreshControlState {
    case Idle
    case Triggered
    case Refreshing
    case NeedsIdle
    case WillIdle
}


@objc public class NefreshControl: UIControl, UIScrollViewDelegate {
    
    weak var activityView: UIActivityIndicatorView!
    weak var imageView: UIImageView!
    var imageViewAnimationKey = "rotationAnimation"
    
    weak var scrollView: UIScrollView?
    var scrollViewInset = UIEdgeInsetsZero
    
    var refreshState: NefreshControlState = .Idle
    
    public static func attachedTo(scrollView: UIScrollView, withImage image: UIImage, target: AnyObject, selector: Selector) -> NefreshControl {
        return NefreshControl(scrollView: scrollView, image: image, target: target, selector: selector)
    }
    
    init(scrollView: UIScrollView, image: UIImage, target: AnyObject, selector: Selector) {
        self.scrollView = scrollView
        self.scrollViewInset = scrollView.contentInset
        
        super.init(frame: CGRectZero)
        
        self.backgroundColor = scrollView.backgroundColor
        self.layoutMargins = UIEdgeInsetsMake(32, 16, 32, 16)
        
        let imageView = UIImageView(image: image)
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .TopMargin,
            multiplier: 1.0,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self,
            attribute: .BottomMargin,
            multiplier: 1.0,
            constant: 0))
        self.imageView = imageView
        
        scrollView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self.scrollView,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.scrollView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0))
        
        self.addTarget(target, action: selector, forControlEvents: .ValueChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    public func beginRefreshing() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        guard self.refreshState == .Idle || self.refreshState == .Triggered else {
            return
        }
        
        let duration: CFTimeInterval = 1
        let rotations = 1
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0 * duration * Double(rotations))
        rotationAnimation.duration = duration;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 99;
        imageView.layer.addAnimation(rotationAnimation, forKey: self.imageViewAnimationKey)
        
        let currentOffset = scrollView.contentOffset
        let insets = self.scrollViewInset
        
        UIView.animateWithDuration(
            0.33,
            delay: 0,
            options: [ .BeginFromCurrentState, .AllowUserInteraction, .CurveEaseInOut ],
            animations: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                let newInsets = UIEdgeInsetsMake(
                    insets.top + CGRectGetHeight(weakSelf.bounds),
                    insets.left,
                    insets.bottom,
                    insets.right)
                scrollView.contentInset = newInsets
                scrollView.contentOffset = currentOffset
            }, completion: { (completed) in
        
        })
        
        self.refreshState = .Refreshing
        self.sendActionsForControlEvents([ .ValueChanged ])
    }
    
    public func endRefreshing() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        guard self.refreshState == .Refreshing || self.refreshState == .NeedsIdle else {
            return
        }
        
        guard scrollView.dragging == false else {
            self.refreshState = .NeedsIdle
            return
        }
        
        let originalInsets = self.scrollViewInset
        
        UIView.animateWithDuration(
            0.33,
            delay: 0,
            options: [ .BeginFromCurrentState, .AllowUserInteraction, .CurveEaseInOut ],
            animations: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.imageView.alpha = 0

                scrollView.contentInset = originalInsets
                scrollView.contentOffset = CGPointZero
            }, completion: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.imageView.layer.removeAnimationForKey(weakSelf.imageViewAnimationKey)
                weakSelf.refreshState = .Idle
        })
        
        self.refreshState = .WillIdle
    }
    
    // MARK: Actions
    
    func process(newOffset offset: CGPoint) {
        guard let scrollView = self.scrollView else {
            return
        }
        
        switch self.refreshState {
        case .Idle:
            let progress = max(min(offset.y / -84, 1.0), 0)
            print("progress: \(progress)")
            self.imageView.alpha = progress
            
            if offset.y <= -84 {
                if scrollView.dragging {
                    self.refreshState = .Triggered
                }
                else {
                    self.beginRefreshing()
                }
            }
            break
        default:
            break
        }
    }
    
    // MARK: <UIScrollViewDelegate>
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        self.process(newOffset: scrollView.contentOffset)
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if self.refreshState == .Triggered {
            self.beginRefreshing()
        }
        else if self.refreshState == .NeedsIdle {
            self.endRefreshing()
        }
    }
}
