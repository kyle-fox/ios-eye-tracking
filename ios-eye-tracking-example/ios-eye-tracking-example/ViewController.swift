//
//  ViewController.swift
//  ios-eye-tracking-example
//
//  Created by Kyle Fox on 6/20/20.
//  Copyright © 2020 Kyle Fox. All rights reserved.
//

import ios_eye_tracking
import UIKit

class ViewController: UIViewController {

    let eyeTracking = EyeTracking()

    override func viewDidLoad() {
        super.viewDidLoad()
        eyeTracking.startSession()
    }
}

