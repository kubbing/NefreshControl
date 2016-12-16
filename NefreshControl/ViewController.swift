//
//  ViewController.swift
//  NefreshControl
//
//  Created by Jakub Hladik on 16/08/16.
//  Copyright © 2016 Jakub Hladik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var refreshControl: NefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let contentSize = CGSize(width: self.view.bounds.width, height: 2*self.view.bounds.height)
        
        self.scrollView.contentSize = contentSize
        self.scrollView.backgroundColor = UIColor.white
        
        self.refreshControl = NefreshControl.attachedTo(
            self.scrollView,
            withImage: UIImage(named: "triangle")!.withRenderingMode(.alwaysTemplate),
            target: self,
            selector: #selector(ViewController.refreshControlValueChanged(_:)))
        self.refreshControl?.tintColor = UIColor.gray
        
        let button = UIButton(type: .system)
        button.setTitle("Refresh!", for: .normal)
        button.addTarget(self, action: #selector(ViewController.refreshButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button" : button]))
        self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Actions
    
    func refreshButtonAction(_ sender: UIButton) {
        self.refreshControl?.beginRefreshing()
        
        let delayTime = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }
    
    func refreshControlValueChanged(_ sender: NefreshControl) {
        let delayTime = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: <UIScrollViewDelegate>
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.refreshControl?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.refreshControl?.scrollViewWillBeginDecelerating(scrollView)
    }
}
