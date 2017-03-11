//
//  ViewController.swift
//  Demo
//
//  Created by Graeme Read on 11/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import UIKit
import HelloWorld


class ViewController: UIViewController {
    
    // MARK: - IBActions
    @IBAction
    private func goOnDoIt() {
        HelloWorld.sayIt()
    }
    
}
