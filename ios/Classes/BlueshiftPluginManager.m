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
    //Send push payload to flutter
    if (config.applicationLaunchOptions) {
        [self sendPushNotificationPayloadToFlutter:config.applicationLaunchOptions];
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
    if (url && options && [options[openURLOptionsSource] isEqual:openURLOptionsBlueshift]) {
        return YES;
    }
    return NO;
}

- (BOOL)isBlueshiftUniversalLinkURL:(NSURL*)url {
    if (url && ([BlueShift.sharedInstance isBlueshiftUniversalLinkURL:url] || [url.absoluteString rangeOfString:kUniversalLinkShortURLKey].location != NSNotFound)) {
        return YES;
    }
    return NO;
}

@end

