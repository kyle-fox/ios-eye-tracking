import EyeTracking
import UIKit

class ViewController: UIViewController {

    let eyeTracking = EyeTracking(configuration: Configuration(appID: "ios-eye-tracking-example"))
    var sessionID: String?
    var sessionTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        startNewSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eyeTracking.showPointer()
    }

    func startNewSession() {
        // Only run 1 session's data at a time
        try? EyeTracking.deleteAll()

        if eyeTracking.currentSession != nil {
            eyeTracking.endSession()
        }

        eyeTracking.startSession()
        eyeTracking.loggingEnabled = true
        sessionID = eyeTracking.currentSession?.id
    }

    @IBAction func startNewSessionTapped(_ sender: Any) {
        startNewSession()
    }

    @IBAction func startDataSession(_ sender: Any) {
        startNewSession()

        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.eyeTracking.loggingEnabled = false
            self.eyeTracking.endSession()
            guard let jsonData = try? EyeTracking.exportAll() else { return }
            let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            print(jsonDict ?? "")
            self.eyeTracking.startSession()
        }
    }

    @IBAction func startScanpathSession(_ sender: Any) {
        startNewSession()

        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.eyeTracking.endSession()
            self.eyeTracking.displayScanpath(for: self.sessionID ?? "", animated: true)
        }
    }

    @IBAction func hideScanpath(_ sender: Any) {
        eyeTracking.hideVisualization()
    }
}
