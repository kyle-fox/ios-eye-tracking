//
//  ViewController.swift
//  ios-eye-tracking-example
//
//  Created by Kyle Fox on 6/20/20.
//  Copyright © 2020 Kyle Fox. All rights reserved.
//

import EyeTracking
import UIKit

class ViewController: UIViewController {

    let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example", blendShapes: [.eyeBlinkLeft, .eyeBlinkRight]))

    override func viewDidLoad() {
        super.viewDidLoad()
        eyeTracking.startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eyeTracking.showPointer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            let newVC = UIViewController()
//            newVC.view.backgroundColor = .white
//            self.present(newVC, animated: true, completion: nil)

            self.eyeTracking.endSession()
            let json = try? self.eyeTracking.exportAllString(with: .useDefaultKeys)
            print("⛔️ \(json ?? "")")
        }
    }
}
