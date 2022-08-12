//
//  BlueshiftPluginManager.h
//  Pods
//
//  Created by Ketan Shikhare on 29/06/22.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <BlueShift_iOS_SDK/BlueShift.h>
#import <UserNotifications/UserNotifications.h>
#import <BlueShift_iOS_SDK/BlueshiftUniversalLinksDelegate.h>

#ifndef BlueshiftPluginManager_h
#define BlueshiftPluginManager_h

#define kBlueshiftDeepLinkEvent                 @"BlueshiftDeepLinkEvent"

@interface BlueshiftPluginManager : NSObject

+ (_Nullable instancetype) sharedInstance;

/// Initialise the Blueshift SDK using Automatic integration. Pass `autoIntegrate` as true to enable the Automatic SDK  integration.
/// Pass `autoIntegrate` as false to integrate the SDK manually.
/// @param config BlueShiftConfig object for SDK intialisation.
/// @param autoIntegrate defines the autoIntegration or manual integration
- (void)initialisePluginWithConfig:(BlueShiftConfig* _Nonnull)config autoIntegrate:(BOOL)autoIntegrate;


/// Send deep link url to dart
/// This method can be used during the manual SDK integration to send deep link to the dart.
/// With automatic inetgration, SDK takes care of sending the deep link to the dart automatically.
/// @param url deep link url
- (void)sendDeepLinkToFlutter:(NSURL* _Nonnull)url;

/// Check if URL received inside the AppDelegate's OpenURL method is from Blueshift or not.
/// @param url URL from the AppDelegate's OpenURL method
/// @param options options from the AppDelegate's OpenURL method
- (BOOL)isBlueshiftOpenURLLink:(NSURL*_Nullable)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *_Nullable)options;

@end

@interface NSObject (BlueshiftReactAutoIntegration)

+ (void)swizzleMainAppDelegate;

@end

#endif /* BlueshiftPluginManager_h */
