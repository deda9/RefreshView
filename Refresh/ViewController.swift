//
//  ViewController.swift
//  Refresh
//
//  Created by Bassem Qoulta on 1/7/19.
//  Copyright © 2019 Bassem Qoulta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
    var refreshView: RefreshView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView = RefreshView(options: [.text("Loading"), .fontSize(22)])
        refreshView.center = self.view.center
        self.view.addSubview(refreshView)
    }
    
    @IBAction func hide(_ sender: Any) {
        refreshView.hideLetters()
    }
    
    @IBAction func show(_ sender: Any) {
        refreshView.showLetters()
    }
}

