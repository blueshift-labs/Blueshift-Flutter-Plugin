import UIKit
import Flutter
import blueshift_plugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, BlueshiftUniversalLinksDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      self.initialiseBlueshiftWithLaunchOptions(launchOptions: launchOptions)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func initialiseBlueshiftWithLaunchOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let config = BlueShiftConfig()
        config.apiKey = "5dfe3c9aee8b375bcc616079b08156d9"
        if let launchOptions = launchOptions {
            config.applicationLaunchOptions = launchOptions
        }
        if #available(iOS 10.0, *) {
            config.userNotificationDelegate = self
        }
        config.enableInAppNotification = true
        config.appGroupID = "group.blueshift.reads"
        config.debug = true
        config.enableMobileInbox =  true
        config.userNotificationDelegate = self
        config.blueshiftUniversalLinksDelegate = self
        BlueshiftPluginManager.sharedInstance()?.initialisePlugin(with: config, autoIntegrate:true)
    }
}

