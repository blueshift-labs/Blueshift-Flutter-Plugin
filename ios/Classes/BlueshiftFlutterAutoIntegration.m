//
//  BlueshiftFlutterAutoIntegration.m
//  blueshift_plugin
//
//  Created by Ketan Shikhare on 28/08/23.
//

#import "BlueshiftFlutterAutoIntegration.h"
#import "BlueshiftPluginManager.h"

#import <objc/runtime.h>
#import "BlueShift.h"
#import "BlueshiftUniversalLinksDelegate.h"

@implementation NSObject (BlueshiftFlutterAutoIntegration)

+ (void)swizzleMainAppDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        id uiApplicationDelegate = [UIApplication sharedApplication].delegate;
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            SEL originalSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            SEL originalSelector = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:didFailToRegisterForRemoteNotificationsWithError:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:didFailToRegisterForRemoteNotificationsWithError:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            SEL originalSelector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:didReceiveRemoteNotification:fetchCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:didReceiveRemoteNotification:fetchCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }

        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            SEL originalSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
            SEL originalSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_userNotificationCenter:willPresentNotification:withCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_userNotificationCenter:willPresentNotification:withCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }

        if ([uiApplicationDelegate respondsToSelector:@selector(application:openURL:options:)]) {
            SEL originalSelector = @selector(application:openURL:options:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:openURL:options:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:openURL:options:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:openURL:options:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if ([uiApplicationDelegate respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            SEL originalSelector = @selector(application:continueUserActivity:restorationHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_application:continueUserActivity:restorationHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        } else {
            SEL originalSelector = @selector(application:continueUserActivity:restorationHandler:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_application:continueUserActivity:restorationHandler:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if (![uiApplicationDelegate respondsToSelector:@selector(didCompleteLinkProcessing:)]) {
            SEL originalSelector = @selector(didCompleteLinkProcessing:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_didCompleteLinkProcessing:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
        
        if (![uiApplicationDelegate respondsToSelector:@selector(didFailLinkProcessingWithError:url:)]) {
            SEL originalSelector = @selector(didFailLinkProcessingWithError:url:);
            SEL swizzledSelector = @selector(blueshift_swizzled_no_didFailLinkProcessingWithError:url:);
            [self swizzleMethodWithClass:class originalSelector:originalSelector andSwizzledSelector:swizzledSelector];
        }
    });
}

+ (void)swizzleMethodWithClass:(Class)class originalSelector:(SEL)originalSelector andSwizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL isSuccess = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isSuccess) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Remote Notification methods
- (void)blueshift_swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSData* cachedDeviceToken = [deviceToken copy];
    [self blueshift_swizzled_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:cachedDeviceToken];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
}

- (void)blueshift_swizzled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    [self blueshift_swizzled_application:application didFailToRegisterForRemoteNotificationsWithError:error];
    
    [[BlueShift sharedInstance].appDelegate failedToRegisterForRemoteNotificationWithError:error];
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    [[BlueShift sharedInstance].appDelegate failedToRegisterForRemoteNotificationWithError:error];
}

- (void)blueshift_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDictionary *cachedUserInfo = [userInfo copy];
    [self blueshift_swizzled_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:cachedUserInfo] == YES) {
        [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:cachedUserInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {}];
    }
}

- (void)blueshift_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:userInfo] == YES) {
        [[BlueShift sharedInstance].appDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

#pragma mark - User Notification methods
- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    UNNotificationResponse * cachedResponse = [response copy];
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:cachedResponse.notification.request.content.userInfo] == YES) {
        // Send completion handler empty to let Blueshift handle it
        [self blueshift_swizzled_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:^{
        }];
        
        [BlueshiftPluginManager.sharedInstance sendPushNotificationPayloadToFlutter:response.notification.request.content.userInfo];
        [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:cachedResponse withCompletionHandler:completionHandler];

    } else {
        [self blueshift_swizzled_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
}

- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:response.notification.request.content.userInfo] == YES) {
        [BlueshiftPluginManager.sharedInstance sendPushNotificationPayloadToFlutter:response.notification.request.content.userInfo];
        [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
}

- (void)blueshift_swizzled_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    UNNotification * cachedNotification = [notification copy];
    if ([[BlueShift sharedInstance]isBlueshiftPushNotification:cachedNotification.request.content.userInfo] == YES) {
        // Send completion handler empty to let Blueshift handle it
        [self blueshift_swizzled_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions options) {
        }];

        [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:cachedNotification withCompletionHandler:completionHandler];
    } else {
        [self blueshift_swizzled_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }
}

- (void)blueshift_swizzled_no_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    if([[BlueShift sharedInstance]isBlueshiftPushNotification:notification.request.content.userInfo] == YES) {
        [[BlueShift sharedInstance].userNotificationDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }
}

#pragma mark - Universal links method
- (void)blueshift_swizzled_no_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if(userActivity && [BlueshiftPluginManager.sharedInstance isBlueshiftUniversalLinkURL:userActivity.webpageURL]) {
        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForActivity:userActivity];
    }
}

- (void)blueshift_swizzled_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSURL *url = userActivity ? [userActivity.webpageURL copy] : nil;
    [self blueshift_swizzled_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    if([BlueshiftPluginManager.sharedInstance isBlueshiftUniversalLinkURL:url]) {
        [[BlueShift sharedInstance].appDelegate handleBlueshiftUniversalLinksForURL:url];
    }
}


#pragma mark - Push & in-app deep linking method
- (void)blueshift_swizzled_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSURL *openedURL = [url copy];
    [self blueshift_swizzled_application:app openURL:url options:options];
    
    if(openedURL) {
        [[BlueshiftPluginManager sharedInstance]sendDeepLinkToFlutter:openedURL];
    }
}

- (void)blueshift_swizzled_no_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    if (url) {
        [[BlueshiftPluginManager sharedInstance]sendDeepLinkToFlutter:url];
    }
}
#pragma mark - BlueshiftUniversalLinksDelegate methods

- (void)blueshift_swizzled_no_didCompleteLinkProcessing:(NSURL *)url {
    if (url) {
        [[BlueshiftPluginManager sharedInstance]sendDeepLinkToFlutter:url];
    }
}

- (void)blueshift_swizzled_no_didFailLinkProcessingWithError: (NSError *_Nullable)error url:(NSURL *_Nullable)url {
    if (url) {
        [[BlueshiftPluginManager sharedInstance]sendDeepLinkToFlutter:url];
    }
}

@end
