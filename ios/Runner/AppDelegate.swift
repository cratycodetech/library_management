import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window?.rootViewController as! FlutterViewController
    let screenProtectionChannel = FlutterMethodChannel(name: "screen_protection",
                                                       binaryMessenger: controller.binaryMessenger)

    screenProtectionChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "enableProtection" {
        // Enable iOS screen protection
        controller.view.window?.layer.superlayer?.addSublayer(self.getScreenProtectionLayer())
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getScreenProtectionLayer() -> CALayer {
    let layer = CALayer()
    layer.frame = UIScreen.main.bounds
    layer.backgroundColor = UIColor.black.cgColor
    layer.opacity = 0.01 // Light transparent layer to prevent screen recording
    return layer
  }
}
