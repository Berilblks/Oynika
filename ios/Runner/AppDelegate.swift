import Flutter
import UIKit

// UIKit landscapeLeft has Home on the left: natural device X points down.
// These interface names are opposite to UIDeviceOrientation's landscape names.
func whoLandscapeUpSign(for orientation: UIInterfaceOrientation) -> Double? {
  switch orientation {
  case .landscapeLeft: return -1.0
  case .landscapeRight: return 1.0
  default: return nil
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(name: "oynika/who_motion", binaryMessenger: controller.binaryMessenger)
        .setMethodCallHandler { [weak controller] call, result in
          guard call.method == "landscapeUpSign" else {
            result(FlutterMethodNotImplemented)
            return
          }
          guard let controller = controller else {
            result(nil)
            return
          }
          let orientation: UIInterfaceOrientation
          if #available(iOS 13.0, *) {
            orientation = controller.view.window?.windowScene?.interfaceOrientation ?? .unknown
          } else {
            orientation = UIApplication.shared.statusBarOrientation
          }
          result(whoLandscapeUpSign(for: orientation))
        }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
