//
//  BlueshiftPluginManager.m
//  blueshift_flutter_plugin
//
//  Created by Ketan Shikhare on 29/06/22.
//

#import "BlueshiftPluginManager.h"
#import <Foundation/Foundation.h>

#import "BlueShift.h"
#import "BlueshiftConstants.h"
#import "BlueShiftNotificationConstants.h"
#import "BlueshiftFlutterAutoIntegration.h"

static BlueshiftPluginManager *_sharedInstance = nil;

@implementation BlueshiftPluginManager {
    NSString* _Nullable lastProcessedPushUUID;
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)initialisePluginWithConfig:(BlueShiftConfig*)config autoIntegrate:(BOOL)autoIntegrate {
    if (autoIntegrate == YES) {
        Class appDelegateClass = [[UIApplication sharedApplication].delegate class];
        [appDelegateClass swizzleMainAppDelegate];
    }
    //If Blueshift push payload, then send push payload to flutter
    if (config.applicationLaunchOptions) {
        NSDictionary *userInfo = [config.applicationLaunchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo && [[BlueShift sharedInstance] isBlueshiftPushNotification:config.applicationLaunchOptions]) {
            [self sendPushNotificationPayloadToFlutter:config.applicationLaunchOptions];
        }
    }
    [BlueShift initWithConfiguration:config];
}

- (void)sendDeepLinkToFlutter:(NSURL*)url {
    if (url && url.absoluteString) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBlueshiftDeepLinkEvent object:url.absoluteString userInfo:nil];
    }
}

- (void)sendPushNotificationPayloadToFlutter:(NSDictionary*)userInfo {
    if (userInfo && ![userInfo[kInAppNotificationModalMessageUDIDKey] isEqualToString:lastProcessedPushUUID]) {
        lastProcessedPushUUID = userInfo[kInAppNotificationModalMessageUDIDKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBlueshiftPushNotificationClickedEvent object:nil userInfo:userInfo];
    }
}

- (BOOL)isBlueshiftOpenURLLink:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[BlueShift sharedInstance] isBlueshiftOpenURLData:url additionalData:options];
}

- (BOOL)isBlueshiftUniversalLinkURL:(NSURL*)url {
    return [[BlueShift sharedInstance] isBlueshiftUniversalLinkURL:url];
}

@end

