//
//  BlockSelectorViewController.swift
//  Galaxy
//
//  Created by Cezar Babin on 4/26/17.
//  Copyright © 2017 Cezar Babin. All rights reserved.
//

import UIKit

class BlockSelectorViewController: UIViewController {

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    override func viewDidLoad() {

        super.awakeFromNib()
        self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + 120,
                            width: UIScreen.main.bounds.width, height: 140)
        
        // Call updateConstraints so self.bounds is the correct size
        self.view.updateConstraints()
        
        let curvedView = CurvedView(frame: self.view.bounds,
                                    curveHeight: 10)
        //self.view.visualEffectView.mask = curvedView
    }
    */
    
}
