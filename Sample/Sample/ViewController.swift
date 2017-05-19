//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2017. 4. 13.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ViewController: UIViewController {

    @IBOutlet var kingghidorahImageView: UIImageView!
    @IBOutlet var godzillaImageView: UIImageView!
    @IBOutlet var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if P9TutorialPlayer.default().playedCount(forKey: sampleKey) == 0 {
            let paramDict = [fullFrameKey:self.view.bounds,
                             kingghidorahFrameKey:self.kingghidorahImageView.frame,
                             godzillaFrameKey:self.godzillaImageView.frame,
                             playButtonFrameKey:self.resetButton.frame]
            P9TutorialPlayer.default().playAction([sampleKey], parameterDict: paramDict, on: self)
        }
    }
    
    @IBAction func resetButtonTouchUpInside(_ sender: UIButton) {
        
        P9TutorialPlayer.default().resetPlayedCount(forKey: sampleKey)
    }
}

