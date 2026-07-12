import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Manual window initialization to fix white screen issues.
    // We use a local variable to safely unwrap and satisfy the Swift compiler.
    if self.window == nil {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = FlutterViewController()
        window.makeKeyAndVisible()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
