# iOS Plugin Integration

After adding the **Blueshift Flutter plugin** to your project, run `pod install` inside the  `iOS` directory. The pod will install the Blueshift plugin along with the Blueshift iOS SDK in your iOS Project.

### Prerequisites

Following permissions needs to be enabled in your Xcode project to send push notifications to the user’s device. 
* To send push notifications, [add **Push Notifications** capability to your app target](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns). 
* To send silent push notifications, [add **Background modes** capability to your App target and enable **Remote notifications** background mode for your app target](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app).

After adding the **Push Notifications** capability and enabling **Remote notifications** background mode, it should look like the below.

![alt text](https://files.readme.io/6b23055-capability.png)
* If you want to send Time Sensitive Push Notifications, add the capability `Time Sensitive Notification` to your app target. 

  

## 1. SDK integration

We have divided the SDK integration into 3 types based on the integration type.

a. [Automatic Integration](#a-automatic-integration) - Blueshift integration when you have not integrated Firebase in your project.

b. [Auto Integration along with Firebase SDK](#b-auto-integration-along-with-firebase-sdk) - Blueshift integration when you have already integrated Firebase in your project.

c. [Manual Integration](#c-manual-integration) - Manual integration for customized implementation. 

### a. Automatic Integration

You can integrate the Blueshift Flutter plugin for your iOS project using Automatic integration, where the Blueshift Plugin can take care of handling the device token, push notification, and deep link callbacks.

Follow the below steps for SDK integration:

#### Setup AppDelegate.h 

To get started, include the Plugin’s header file in the `AppDelegate.h` file of the app’s Xcode project.

Include the Plugin’s header `BlueshiftPluginManager.h` in `AppDelegate.h` and also add the `UNUserNotificationCenterDelegate` protocol on `AppDelegate` class. The `AppDelegate.h` should like:

```objective-c
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

#import <blueshift_flutter_plugin/BlueshiftPluginManager.h>

@interface AppDelegate : FlutterAppDelegate <UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UIWindow *window;

@end
```

#### Setup AppDelegate.m 

Now open `AppDelegate.m` file and add the following function in the `AppDelegate` class. In the function, we have created an object of `BlueshiftConfig` class to set up the API key and the other SDK configuration. Initialise the Blueshift Flutter plugin using `BlueshiftPluginManager` class method `initialisePluginWithConfig: autoIntegrate:`. Pass the created config object and `autoIntegrate` as `YES` to opt-in for automatic integration.

```objective-c

- (void)initialiseBlueshiftWithLaunchOptions:(NSDictionary*)launchOptions {
  // Create config object
  BlueShiftConfig *config = [[BlueShiftConfig alloc] init];
  
  // Set Blueshift API key to SDK
  config.apiKey = @"API KEY";
 
  // Set launch options to track the push click from killed app state
  config.applicationLaunchOptions = launchOptions;
    
  // Delay push permission dialog by setting NO, by default push permission dialog is displayed on app launch.
  config.enablePushNotification = YES;
  
  // Set userNotificationDelegate to self to get the push notification callbacks.
  config.userNotificationDelegate = self;
  
  // Initialise the Plugin and SDK using the Automatic integration.
  [[BlueshiftPluginManager sharedInstance] initialisePluginWithConfig:config autoIntegrate:YES];
}

```

Now call above function inside the `application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` method of the `AppDelegate` class. The `AppDelegate.m` file will look like this:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    // Initialise the Blueshift Plugin & SDK by calling the `initialiseBlueshiftWithLaunchOptions` method before the return statement.
    [self initialiseBlueshiftWithLaunchOptions:launchOptions];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

#### SDK Config values
The other optional SDK config values which can be used to configure the SDK are:

```Objective-c

  // Optional:  Set Blueshift Region US or EU, default region will be the US if not set.
  [config setRegion:BlueshiftRegionEU];

  // Optional: Set AppGroupId only if you are using the Carousel push notifications.
  [config setAppGroupID:@"Your App Group ID here"];

  // Optional: Set custom authorization options
  [config setCustomAuthorizationOptions: UNAuthorizationOptionAlert| UNAuthorizationOptionSound| UNAuthorizationOptionBadge| UNAuthorizationStatusProvisional];

  // Optional: Set App's push notification custom categories, SDK will register them
  [config setCustomCategories: [self getCustomeCategories]];
  
  // Optional: Set Batch upload interval in seconds.
  // If you do not add the below line, SDK by default sets it to 300 seconds.
  [[BlueShiftBatchUploadConfig sharedInstance] setBatchUploadTimer:60.0];

  // Optional: Set device Id type, SDK uses IDFV by default if you do not
  // Add the below line of code. For more information, see:
  //https://developer.blueshift.com/docs/include-configure-initialize-the-ios-sdk-in-the-app#specify-the-device-id-source
  [config setBlueshiftDeviceIdSource: BlueshiftDeviceIdSourceIDFVBundleID];

  // Optional: Change the SDK core data files location only if needed. The default location is the Document directory.
  [config setSdkCoreDataFilesLocation:BlueshiftFilesLocationLibraryDirectory];

  //Optional: Set debug true to see Blueshift SDK info and API logs, by default it's set as false.
  #ifdef DEBUG
        [config setDebug:YES];
  #endif

```
You can find more information on the SDK config values [here](https://developer.blueshift.com/docs/include-configure-initialize-the-ios-sdk-in-the-app#sdk-config-values). 

The SDK setup with automatic integration completes over here. Using this setup you will be able to send events to Blueshift, send basic push notifications (title+content) to the iOS device. Also, you will get the push notification deep links in your Flutter app using the [Deep links Event Listener](README.md#deep-links-event-listener).

Refer [section](#2-enable-rich-push-notifications) to enable Rich push notifications, [section](#3-enable-in-app-messages) to enable in-app notifications and [section](#4-enable-blueshift-email-deep-links) to enable Blueshift email deep links. 


### b. Auto Integration along with Firebase SDK
As Blueshift and Firebase both are responsible for handling the push notifications and both provide the automatic integration feature, you can not use Blueshift Auto integration when you have integrated Firebase SDK with auto integration(method swizzling). You can follow the above-mentioned steps from [a. Automatic Integration](#a-automatic-integration) to do the Blueshift SDK integration, and after that, disable the Firebase auto integration and integrate manually by following the below steps.

You will need to disable the Method Swizzling for Firebase first. To disable it, add `FirebaseAppDelegateProxyEnabled` key with type `Boolean` and value `NO` in `info.plist` from your app's target.

As we have disabled the Firebase method swizzling, we need to explicitly set the APNS token to Firebase. To do that, add the below method in your `AppDelegate.m` file. 

```Objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Set device token to Firebase when the method swizzling is disabled.
    [[FIRMessaging messaging] setAPNSToken:deviceToken];
    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
```
Here, the Blueshift Auto integration setup along with the Firebase completes. Using this setup you will be able to send events to Blueshift and send basic push notifications (title+content) to the iOS device. Also, you will get the push notification deep links in your Flutter app using the [Deep links Event Listener](README.md#deep-links-event-listener).

Refer [section](#2-enable-rich-push-notifications) to enable Rich push notifications, [section](#3-enable-in-app-messages) to enable in-app notifications and [section](#4-enable-blueshift-email-deep-links) to enable Blueshift email deep links.  

### c. Manual Integration
In case, none of the above integration types works for you, you can integrate the Blueshift plugin manually. You will need to follow the steps mentioned in the [a. Automatic Integration](#a-automatic-integration) section to create the Blueshift **Config** and then initialize the Plugin by passing `autoIntegrate` as `NO`. 

```objective-c
  // Create Blueshift config and then initialize the Plugin with `autoIntegrate` as `NO`.
  [[BlueshiftPluginManager sharedInstance] initialisePluginWithConfig:config autoIntegrate:NO];
```

Now, as you are doing manual integration, follow the below steps to integrate the Blueshift SDK manually to handle push notifications and deep link callbacks. 

#### Configure AppDelegate for push notifications
Add the following to the `AppDelegate.m` file of your app’s Xcode project to support the push notifications. Refer [this section](https://developer.blueshift.com/docs/include-configure-initialize-the-ios-sdk-in-the-app#configure-appdelegate-for-push-notifications) for more information.

```objective-c
#pragma mark - remote notification delegate methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [[BlueShift sharedInstance].appDelegate failedToRegisterForRemoteNotificationWithError:error];
    [super application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    // If Blueshift push, let Blueshift SDK handle it.
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo] == YES) {
        [[BlueShift sharedInstance].appDelegate handleRemoteNotification:userInfo forApplication:application fetchCompletionHandler:handler];
    } else {
        //Let the Flutter handle the Notifications other than Blueshift
        [super application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
    }
}

#pragma mark - UserNotificationCenter delegate methods
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary* userInfo = notification.request.content.userInfo;
    // If Blueshift push, let Blueshift SDK handle it.
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo]) {
        [[BlueShift sharedInstance].userNotificationDelegate handleUserNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    } else {
        //Let the Flutter handle the Notifications other than Blueshift
        [super userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary* userInfo = response.notification.request.content.userInfo;
    // If Blueshift push, let Blueshift SDK handle it.
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo]) {
        [[BlueShift sharedInstance].userNotificationDelegate handleUserNotification:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    } else {
        //Let the Flutter handle the Notifications other than Blueshift
        [super userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
}

```
#### Handle the push and in-app deep links manually
The Blueshift iOS SDK supports deep links on push notifications and in-app messages. If a deep-link URL is present in the push or in-app message payload, the Blueshift SDK triggers `AppDelegate` class `application:openURL:options:` method on notification click/tap action and delivers the deep link there. If the URL is from Blueshift, then let the plugin manager send it to Flutter using the [Deep links Event Listener](README.md#deep-links-event-listener). Add the below code to the `AppDelegate.m` file.

```objective-c
/// Override the open url method for handling deep links
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options { 
    // Check if the received link is from Blueshift, then pass it to Blueshift plugin to handle it.
    if ([[BlueshiftPluginManager sharedInstance] isBlueshiftOpenURLLink:url options:options] == YES) {
        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
    } else {
        // If the url is not from Blueshift, let Flutter handle it.
        [super application:application openURL:url options:options];
    }
    return YES;
}
```



## 2. Enable Rich push notifications

Blueshift supports Image, Carousel, and Custom action button push notifications.

- **Support Rich image and Custom action button push notifications** - you will need to add the `Notification service extension` to your project and integrate the `Blueshift-iOS-Extension-SDK`. Follow [this document](https://developer.blueshift.com/docs/integrate-your-ios-apps-notifications-with-blueshift#set-up-notification-service-extension) for step by step guide to enable Rich image and Custom action button push notifications.  

  To know more about the custom action button push notifications, refer to [this](https://developer.blueshift.com/docs/integrate-your-ios-apps-notifications-with-blueshift#custom-action-button-push-notifications) document.

- **Support Carousel push notifications** - You will need to integrate the `Notification service extension` and then add `Notification content extension`. Follow [this document](https://developer.blueshift.com/docs/integrate-your-ios-apps-notifications-with-blueshift#set-up-notification-content-extension) for step by step guide to enable carousel push notifications. Make sure you set the App group id, `App group id` is mandatory to set in your app targets when you use carousel push notifications. Refer to [this document](https://developer.blueshift.com/docs/integrate-your-ios-apps-notifications-with-blueshift#add-an-app-group) to create and set up an app group id for your project.



## 3. Enable In-App Messages

By default, In-app messages are disabled in the SDK. You will need to enable it explicitly from the Blueshift config.

#### Enable In-App messages from Blueshift Config
During the SDK initialisation in `AppDelegate.m` file, we have set the values to the config. You need to set `enableInAppNotification` property of config to `YES` to enable in-app messages from Blueshift iOS SDK. 

```objective-c 
[config setEnableInAppNotification:YES];

```

#### Configure time intervals between two in-apps
By default, the time interval between two in-app messages (the interval when a message is dismissed and the next message appears) is one minute. You can use the following method to change this interval during the SDK initialization in the `AppDelegate.m` file:

```objective-c
// Set time interval in seconds
[config setBlueshiftInAppNotificationTimeInterval:30];
```

#### Enable Background Modes
We highly recommend enabling Background fetch and Remote notifications background modes from the Signing & Capabilities. This will enable the app to fetch the in-app messages if the app is in the background state.

![alt_text](https://files.readme.io/31d15b6-Screenshot_2020-07-14_at_7.02.38_PM.png)

#### Register screens for in-app messages
Once you enable the In-app messages, you will need to register the Flutter app screens for receiving the in-app messages. You can register the screens in two ways.

- **Register all screens** in Xcode project to receive in-app messages.
You need to add `registerForInAppMessage` line in the `AppDelegate.m` file immediately after the SDK initialisation line irrespective of automatic or manual integration. Refer to the below code snippet for reference. 

```objective-c
  [[BlueshiftPluginManager sharedInstance] initialisePluginWithConfig:config autoIntegrate:YES];
  [[BlueShift sharedInstance] registerForInAppMessage:@"Flutter"];
```

- **Register and unregister each screen** of your Flutter app for in-app messages. If you don’t register a screen for in-app messages, the in-app messages will stop showing up for screens that are not registered. Refer to the below code snippet for reference. 

```Javascript
    // Register for in-app notification
    Blueshift.registerForInAppMessage("HomeScreen");
  
    // Unregister for in-app notification
    Blueshift.unregisterForInAppMessage();
```
## 4. Enable Blueshift email deep links
Blueshift’s deep links are the HTTPS URLs that take users to a page in the app or launch them in a browser. If an email or text message that we send as a part of your campaign contains a Blueshift deep link and a user clicks on it, iOS will launch the installed app and Blueshift SDK will deliver the deep link url to the app, so that the app can perform some action or navigate the user to the respective screen. To set up the Blueshift email deep links,

- Complete the CNAME and AASA configuration as mentioned in the `Prerequisites` section of [this document](https://developer.blueshift.com/docs/integrate-blueshifts-universal-links-ios#prerequisites).

- Add associated domains to your Xcode project as mentioned in the `Integration` section of [this document](https://developer.blueshift.com/docs/integrate-blueshifts-universal-links-ios#integration).

- Follow the below steps to enable Blueshift deep links from the SDK.

Implement protocol `BlueshiftUniversalLinksDelegate` on the AppDelegate class to get the deep links callbacks from the SDK. You `AppDelegate.h` will look like the below,

```objective-c
#import <blueshift_flutter_plugin/BlueshiftPluginManager.h>

@interface AppDelegate : FlutterAppDelegate <UNUserNotificationCenterDelegate, BlueshiftUniversalLinksDelegate>

@end
```
Now set the `blueshiftUniversalLinksDelegate` config variable to `self` to enable the Blueshift deep links during the Blueshift Plugin initialisation in `AppDelegate.m` file. 

```objective-c
  // If you want to use the Blueshift universal links, then set the delegate as below.
  config.blueshiftUniversalLinksDelegate = self;
```

### Automatic Integration 
If you have integrated the plugin using the automatic integration, your setup is completed here. You will receive the deep link on the Flutter using the [Deep links Event Listener](README.md#deep-links-event-listener).

### Manual Integration
If you have opted for Manual integration, you will need to follow the below steps to integrate the Blueshift Plugin.

#### Configure continueUserActivity method
Pass the URL/activity from the `continueUserActivity` method to the Plugin, so that the Plugin can process the URL and perform the click tracking. After processing the URL, the SDK sends the original URL in the `BlueshiftUniversalLinksDelegate` method. Add the below code to the `AppDelegate.m` file.

```objective-c
// Override the `application:continueUserActivity:` method for handling the universal links
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    // Check if the received URL is Blueshift universal link URL, then pass it to Blueshift plugin to handle it.
    if ([[BlueShift sharedInstance] isBlueshiftUniversalLinkURL:userActivity.webpageURL] == YES) {
        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForActivity:userActivity];
    } else {
        // If the activity url is not from Blueshift, let Flutter handle it
        [super application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    return YES;
}
```

#### Implement BlueshiftUniversalLinksDelegate
Now, implement the `BlueshiftUniversalLinksDelegate` delegate methods to get the success and failure callbacks. `BlueshiftPluginManager` will take care of sending the deep link to Flutter. Add the below code to your `AppDelegate.m` file.

```objective-c
// Deep link processing success callback
- (void)didCompleteLinkProcessing:(NSURL *)url {
    if (url) {
        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
    }
}

// Deep link processing failure callback
- (void)didFailLinkProcessingWithError:(NSError *)error url:(NSURL *)url {
    if (url) {
        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
    }
}
```

The manual setup for Blueshift email deep links completes here. You will receive the deep link on the Flutter using the [Deep links Event Listener](README.md#deep-links-event-listener).

Refer to the Troubleshooting section of [this document](https://developer.blueshift.com/docs/integrate-blueshifts-universal-links-ios#troubleshooting) to 
troubleshoot the Universal links integration issues.
