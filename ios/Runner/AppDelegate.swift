import Flutter
import UIKit
import workmanager_apple

// Sin comprobar: solo se puede compilar en una Mac (docs/04-mobile-integration.md).
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // El worker corre en otro motor: sin esto no tendría plugins.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // El mismo id de SyncScheduler.taskName y de BGTaskSchedulerPermittedIdentifiers.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "atelier.sync",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
