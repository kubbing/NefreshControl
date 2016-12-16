//
//  NefreshControl.swift
//  NefreshControl
//
//  Created by Jakub Hladik on 16/08/16.
//  Copyright © 2016 Jakub Hladik. All rights reserved.
//

import UIKit


enum NefreshControlState {
    case idle
    case triggered
    case refreshing
    case needsIdle
    case willIdle
}


@objc open class NefreshControl: UIControl, UIScrollViewDelegate {
    
    fileprivate weak var activityView: UIActivityIndicatorView!
    fileprivate weak var imageView: UIImageView!
    fileprivate let imageViewAnimationKey = "rotationAnimation"
    
    fileprivate weak var scrollView: UIScrollView?
    fileprivate var scrollViewInset = UIEdgeInsets.zero
    
    fileprivate var refreshState: NefreshControlState = .idle
    
    open static func attachedTo(_ scrollView: UIScrollView, withImage image: UIImage, target: AnyObject, selector: Selector) -> NefreshControl {
        return NefreshControl(scrollView: scrollView, image: image, target: target, selector: selector)
    }
    
    fileprivate init(scrollView: UIScrollView, image: UIImage, target: AnyObject, selector: Selector) {
        self.scrollView = scrollView
        self.scrollViewInset = scrollView.contentInset
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = scrollView.backgroundColor
        self.layoutMargins = UIEdgeInsetsMake(32, 16, 32, 16)
        
        let imageView = UIImageView(image: image)
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .topMargin,
            multiplier: 1.0,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: imageView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottomMargin,
            multiplier: 1.0,
            constant: 0))
        self.imageView = imageView
        
        scrollView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: self.scrollView,
            attribute: .width,
            multiplier: 1.0,
            constant: 0.0))
        scrollView.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.scrollView,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0))
        
        self.addTarget(target, action: selector, for: .valueChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    open func beginRefreshing() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        guard self.refreshState == .idle || self.refreshState == .triggered else {
            return
        }
        
        let duration: CFTimeInterval = 1
        let rotations = 1
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotationAnimation.toValue = NSNumber(value: M_PI * 2.0 * duration * Double(rotations) as Double)
        rotationAnimation.duration = duration;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = 99;
        imageView.layer.add(rotationAnimation, forKey: self.imageViewAnimationKey)
        
        let currentOffset = scrollView.contentOffset
        var targetOffset = currentOffset
        if currentOffset == CGPoint.zero {
            targetOffset.y -= self.bounds.height
        }
        let insets = self.scrollViewInset
        
        UIView.animate(
            withDuration: 0.30,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                let newInsets = UIEdgeInsetsMake(
                    insets.top + weakSelf.bounds.height,
                    insets.left,
                    insets.bottom,
                    insets.right)
                scrollView.contentInset = newInsets
                scrollView.contentOffset = targetOffset
            }, completion: { (completed) in
                
        })
        
        self.refreshState = .refreshing
    }
    
    fileprivate func notify() {
        self.sendActions(for: [ .valueChanged ])
    }
    
    open func endRefreshing() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        guard self.refreshState == .refreshing || self.refreshState == .needsIdle else {
            return
        }
        
        guard scrollView.isDragging == false else {
            self.refreshState = .needsIdle
            return
        }
        
        let originalInsets = self.scrollViewInset
        
        UIView.animate(
            withDuration: 0.30,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.imageView.alpha = 0

                scrollView.contentInset = originalInsets
                scrollView.contentOffset = CGPoint.zero
            }, completion: { [weak self] (completed) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.imageView.layer.removeAnimation(forKey: weakSelf.imageViewAnimationKey)
                weakSelf.refreshState = .idle
        })
        
        self.refreshState = .willIdle
    }
    
    // MARK: Actions
    
    fileprivate func process(newOffset offset: CGPoint) {
        guard let scrollView = self.scrollView else {
            return
        }
        
        switch self.refreshState {
        case .idle:
            let progress = max(min(offset.y / -84, 1.0), 0)
            self.imageView.alpha = progress
            
            if offset.y <= -84 {
                if scrollView.isDragging {
                    self.refreshState = .triggered
                }
                else {
                    self.beginRefreshing()
                    self.notify()
                }
            }
            break
        default:
            break
        }
    }
    
    // MARK: <UIScrollViewDelegate>
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.process(newOffset: scrollView.contentOffset)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if self.refreshState == .triggered {
            self.beginRefreshing()
            self.notify()
        }
        else if self.refreshState == .needsIdle {
            self.endRefreshing()
        }
    }
}
