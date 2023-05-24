#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
@import FirebaseMessaging;
@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    // Initialise the Plugin & SDK by calling the `initialiseBlueshiftWithLaunchOptions` method before the return statment.
    [self initialiseBlueshiftWithLaunchOptions:launchOptions];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)initialiseBlueshiftWithLaunchOptions:(NSDictionary*)launchOptions {
    BlueShiftConfig *config = [[BlueShiftConfig alloc] init];
    config.apiKey = @"API_KEY";
    config.enableInAppNotification = YES;
    config.enableMobileInbox = YES;
    // Delay push permission
    config.enablePushNotification = YES;
    config.debug = YES;
    
    config.userNotificationDelegate = self;
    config.blueshiftUniversalLinksDelegate = self;
    config.applicationLaunchOptions = launchOptions;
    config.blueshiftDeviceIdSource = BlueshiftDeviceIdSourceUUID;
    // If Automatic integration
    [BlueshiftPluginManager.sharedInstance initialisePluginWithConfig:config autoIntegrate:YES];
    
    // If Manual integration
    //[BlueshiftPluginManager.sharedInstance initialisePluginWithConfig:config autoIntegrate:YES];
    
    // In App registration for all screens
    //[[BlueShift sharedInstance] registerForInAppMessage:@"Flutter"];
}

#pragma mark - Firebase integration with Blueshift Auto integration
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FIRMessaging messaging] setAPNSToken:deviceToken];
    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}


#pragma mark - Manual integration

//#pragma mark - remote notification delegate methods
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
//    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//}
//
//- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
//    [[BlueShift sharedInstance].appDelegate failedToRegisterForRemoteNotificationWithError:error];
//    [super application:application didFailToRegisterForRemoteNotificationsWithError:error];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
//    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo] == YES) {
//        [[BlueShift sharedInstance].appDelegate handleRemoteNotification:userInfo forApplication:application fetchCompletionHandler:handler];
//    } else {
//        //Let the Flutter handle the Notifications other than Blueshift
//        [super application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
//    }
//}
//
//#pragma mark - UserNotificationCenter delegate methods
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
//    NSDictionary* userInfo = notification.request.content.userInfo;
//    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo]) {
//        [[BlueShift sharedInstance].userNotificationDelegate handleUserNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
//    } else {
//        //Let the Flutter handle the Notifications other than Blueshift
//        [super userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
//    }
//}
//
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
//    NSDictionary* userInfo = response.notification.request.content.userInfo;
//
//    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo]) {
//        // Call Blueshift method to handle the push notification click
//        [[BlueShift sharedInstance].userNotificationDelegate handleUserNotification:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
//    } else {
//        //Let the Flutter handle the Notifications other than Blueshift
//        [super userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
//    }
//}
//
//#pragma mark - open url method
///// Override the open url method for handling deep links
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options { // Check if the received link is from Blueshift, then pass it to Blueshift plugin to handle it.
//    if ([[BlueshiftPluginManager sharedInstance] isBlueshiftOpenURLLink:url options:options] == YES) {
//        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
//    } else {
//        // If the url is not from Blueshift, let Flutter handle it.
//        [super application:application openURL:url options:options];
//    }
//    return YES;
//}
//
//#pragma mark - Universal links
//
//// Override the `application:continueUserActivity:` method for handling the universal links
//- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity
// restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    // Check if the received URL is Blueshift universal link URL, then pass it to Blueshift plugin to handle it.
//    if ([[BlueshiftPluginManager sharedInstance] isBlueshiftUniversalLinkURL:userActivity.webpageURL] == YES) {
//        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForActivity:userActivity];
//    } else {
//        // If the activity is not from Blueshift, let Flutter handle it
//        [super application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
//    }
//    return YES;
//}
//
//// Deep link processing success callback
//- (void)didCompleteLinkProcessing:(NSURL *)url {
//    if (url) {
//        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
//    }
//}
//
//// Deep link processing failure callback
//- (void)didFailLinkProcessingWithError:(NSError *)error url:(NSURL *)url {
//    if (url) {
//        [[BlueshiftPluginManager sharedInstance] sendDeepLinkToFlutter:url];
//    }
//}

@end
