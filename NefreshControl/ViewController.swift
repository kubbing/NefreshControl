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
        let contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 2*CGRectGetHeight(self.view.bounds))
        
        self.scrollView.contentSize = contentSize
        self.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.refreshControl = NefreshControl.attachedTo(
            self.scrollView,
            withImage: UIImage(named: "<image>")!.imageWithRenderingMode(.AlwaysTemplate),
            target: self,
            selector: #selector(ViewController.refreshControlValueChanged(_:)))
        self.refreshControl?.tintColor = UIColor.grayColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Actions
    
    func refreshControlValueChanged(sender: NefreshControl) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: <UIScrollViewDelegate>
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.refreshControl?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        self.refreshControl?.scrollViewWillBeginDecelerating(scrollView)
    }
}
