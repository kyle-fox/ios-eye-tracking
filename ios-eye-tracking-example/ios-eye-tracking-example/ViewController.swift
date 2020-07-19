import EyeTracking
import UIKit

class ViewController: UIViewController {

    let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example", blendShapes: [.eyeBlinkLeft, .eyeBlinkRight]))
    var sessionID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        eyeTracking.startSession()
        eyeTracking.loggingEnabled = true
        sessionID = eyeTracking.currentSession?.id
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eyeTracking.showPointer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.eyeTracking.endSession()
            EyeTracking.displayScanpath(for: self.sessionID ?? "", animated: true)
        }
    }
}
