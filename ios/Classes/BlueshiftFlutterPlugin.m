#import <CoreLocation/CoreLocation.h>

#import "BlueshiftFlutterPlugin.h"
#import "BlueShift.h"
#import "BlueshiftInboxManager.h"
#import "BlueshiftVersion.h"
#import "BlueshiftNotificationConstants.h"
#import "BlueshiftPluginManager.h"
#import "InAppNotificationEntity.h"
#import "BlueshiftConstants.h"
#import "BlueshiftInboxNavigationViewController.h"

@interface BlueshiftFlutterPlugin()
    @property BlueshiftStreamHandler *deeplinkStreamHandler;
    @property BlueshiftStreamHandler *inboxEventStreamHandler;
@end

@implementation BlueshiftFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    BlueshiftFlutterPlugin* instance = [[BlueshiftFlutterPlugin alloc] init];
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:kBlueshiftMethodChannel binaryMessenger:[registrar messenger]];
    //setup deep link event
    FlutterEventChannel *deepLinkEventChannel = [FlutterEventChannel eventChannelWithName:kBlueshiftEventChannel binaryMessenger:[registrar messenger]];
    instance.deeplinkStreamHandler = [BlueshiftStreamHandler new];
    [deepLinkEventChannel setStreamHandler:instance.deeplinkStreamHandler];
    
    //setup inbox event
    FlutterEventChannel *inboxEventChannel = [FlutterEventChannel eventChannelWithName:kBlueshiftInboxEventChannel binaryMessenger:[registrar messenger]];
    instance.inboxEventStreamHandler = [BlueshiftStreamHandler new];
    [inboxEventChannel setStreamHandler:instance.inboxEventStreamHandler];
    
    [instance setupObservers];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserverForName:kBlueshiftDeepLinkEvent object:nil queue: [NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (note.object) {
            [self->_deeplinkStreamHandler sendData:note.object];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kBSInboxUnreadMessageCountDidChange object:nil queue: [NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self->_inboxEventStreamHandler sendData:@"InboxDataChangeEvent"];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kBSInAppNotificationDidAppear object:nil queue: [NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self->_inboxEventStreamHandler sendData:@"InAppLoadEvent"];
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"identifyWithDetails" isEqualToString:call.method]) {
      [self identify:call];
  } else if ([@"trackCustomEvent" isEqualToString:call.method]) {
      [self trackCustomEvent:call];
  } else if ([@"trackScreenView" isEqualToString:call.method]) {
      [self trackScreenView:call];
  } else if ([@"requestPushNotificationPermission" isEqualToString:call.method]) {
      [self registerForRemoteNotification];
  } else if ([@"registerForInAppMessage" isEqualToString:call.method]) {
      [self registerForInAppMessage:call];
  } else if ([@"unregisterForInAppMessage" isEqualToString:call.method]) {
      [self unregisterForInAppMessage];
  } else if ([@"fetchInAppNotification" isEqualToString:call.method]) {
      [self fetchInAppNotification];
  } else if ([@"displayInAppNotification" isEqualToString:call.method]) {
      [self displayInAppNotification];
  } else if ([@"handleDataMessage" isEqualToString: call.method]) {
      // Placeholder method for Android
  } else if ([@"setUserInfoEmailId" isEqualToString:call.method]) {
      [self setUserInfoEmailId:call];
  } else if ([@"setUserInfoCustomerId" isEqualToString:call.method]) {
      [self setUserInfoCustomerId:call];
  } else if ([@"setUserInfoExtras" isEqualToString:call.method]) {
      [self setUserInfoExtras:call];
  } else if ([@"setUserInfoFirstName" isEqualToString:call.method]) {
      [self setUserInfoFirstName:call];
  } else if ([@"setUserInfoLastName" isEqualToString:call.method]) {
      [self setUserInfoLastName:call];
  } else if ([@"removeUserInfo" isEqualToString:call.method]) {
      [self removeUserInfo];
  } else if ([@"resetDeviceId" isEqualToString:call.method]) {
      [self resetDeviceId];
  } else if ([@"setEnablePush" isEqualToString:call.method]) {
      [self setEnablePush:call];
  } else if ([@"setEnableInApp" isEqualToString:call.method]) {
      [self setEnableInApp:call];
  } else if ([@"setEnableTracking" isEqualToString:call.method]) {
      [self setEnableTracking:call];
  } else if ([@"setIDFA" isEqualToString:call.method]) {
      [self setIDFA:call];
  } else if ([@"setCurrentLocation" isEqualToString:call.method]) {
     [self setCurrentLocation:call];
  } else if ([@"getEnableInAppStatus" isEqualToString:call.method]) {
      [self getEnableInAppStatus:result];
      return;
  } else if ([@"getEnablePushStatus" isEqualToString:call.method]) {
      [self getEnablePushStatus:result];
      return;
  } else if ([@"getEnableTrackingStatus" isEqualToString:call.method]) {
      [self getEnableTrackingStatus:result];
      return;
  } else if ([@"getUserInfoFirstName" isEqualToString:call.method]) {
      [self getUserInfoFirstName:result];
      return;
  } else if ([@"getUserInfoLastName" isEqualToString:call.method]) {
      [self getUserInfoLastName:result];
      return;
  } else if ([@"getUserInfoEmailId" isEqualToString:call.method]) {
      [self getUserInfoEmailId:result];
      return;
  } else if ([@"getUserInfoCustomerId" isEqualToString:call.method]) {
      [self getUserInfoCustomerId:result];
      return;
  } else if ([@"getUserInfoExtras" isEqualToString:call.method]) {
      [self getUserInfoExtras:result];
      return;
  } else if ([@"getCurrentDeviceId" isEqualToString:call.method]) {
      [self getCurrentDeviceId:result];
      return;
  } else if ([@"getInitialUrl" isEqualToString: call.method]) {
    // Placeholder method for Android
    result(@"");
    return;
  } else if ([@"liveContentByEmailId" isEqualToString:call.method]) {
      [self getLiveContentByEmail:call callback:result];
      return;
  } else if ([@"liveContentByCustomerId" isEqualToString:call.method]) {
      [self getLiveContentByCustomerId:call callback:result];
      return;
  } else if ([@"liveContentByDeviceId" isEqualToString:call.method]) {
      [self getLiveContentByDeviceId:call callback:result];
      return;
  } else if ([@"getInboxMessages" isEqualToString:call.method]) {
      [self getInboxMessages:result];
      return;
  } else if ([@"getUnreadInboxMessageCount" isEqualToString:call.method]) {
      [self getUnreadInboxMessageCount:result];
      return;
  } else if ([@"syncInboxMessages" isEqualToString:call.method]) {
      [self syncInboxMessages:result];
      return;
  } else if ([@"showInboxMessage" isEqualToString:call.method]) {
      [self showInboxMessage:call];
      return;
  } else if ([@"deleteInboxMessage" isEqualToString:call.method]) {
      [self deleteInboxMessage:call callback:result];
      return;
  } else {
    result(FlutterMethodNotImplemented);
    return;
  }
    result(nil);
}

#pragma mark Events
- (void)identify:(FlutterMethodCall*)call {
    NSDictionary *details = [self addFLSDKVersionString:call.arguments[@"eventData"]];
    [[BlueShift sharedInstance] identifyUserWithDetails:details canBatchThisEvent:NO];
}

- (void)trackCustomEvent:(FlutterMethodCall*)call {
    NSString *eventName = call.arguments[@"eventName"];
    NSNumber* isBatch = (NSNumber*)call.arguments[@"isBatch"];
    NSDictionary *details = call.arguments[@"eventData"];
    if ([eventName isKindOfClass:[NSString class]]) {
        [[BlueShift sharedInstance] trackEventForEventName:eventName andParameters:[self addFLSDKVersionString:details] canBatchThisEvent:isBatch.boolValue];
    }
}

- (void)trackScreenView:(FlutterMethodCall*)call {
    NSString *screenName = call.arguments[@"screenName"];
    NSNumber* isBatch = (NSNumber*)call.arguments[@"isBatch"];
    NSDictionary *details = call.arguments[@"eventData"];
    
    if ([screenName isKindOfClass:[NSString class]]) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if ([details isKindOfClass:[NSDictionary class]]) {
            [params addEntriesFromDictionary:details];
        }
        params[kScreenViewed] = screenName;
        [[BlueShift sharedInstance] trackEventForEventName:kEventPageLoad andParameters:[self addFLSDKVersionString:params] canBatchThisEvent:isBatch.boolValue];
    }
}

#pragma mark Push Notifications
- (void)registerForRemoteNotification {
    [[[BlueShift sharedInstance] appDelegate] registerForNotification];
}

#pragma mark InApp Notifications
- (void)registerForInAppMessage:(FlutterMethodCall*)call {
    NSString *screenName = call.arguments[@"screenName"];

    if ([screenName isKindOfClass:[NSString class]]) {
        [[BlueShift sharedInstance] registerForInAppMessage:screenName];
    }
}

- (void)unregisterForInAppMessage {
    [[BlueShift sharedInstance] unregisterForInAppMessage];
}

- (void)fetchInAppNotification {
    [[BlueShift sharedInstance] fetchInAppNotificationFromAPI:^{
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)displayInAppNotification {
    [[BlueShift sharedInstance] displayInAppNotification];
}

#pragma mark Inbox
-(void)syncInboxMessages:(FlutterResult)callback {
    [BlueshiftInboxManager syncInboxMessages:^{
        callback([NSNumber numberWithBool:YES]);
    }];
}

-(void)getUnreadInboxMessageCount:(FlutterResult)callback {
    [BlueshiftInboxManager getInboxUnreadMessagesCount:^(BOOL status, NSUInteger count) {
        if (status) {
            callback([NSNumber numberWithUnsignedInteger:count]);
        } else {
            callback([NSNumber numberWithUnsignedInteger:0]);
        }
    }];
}

-(void)getInboxMessages:(FlutterResult)callback {
    [BlueshiftInboxManager getCachedInboxMessagesWithHandler:^(BOOL status, NSMutableArray<BlueshiftInboxMessage *> * _Nullable messages) {
        if (status && messages.count > 0) {
            NSMutableArray* convertedMessages = [[NSMutableArray alloc] init];
            [messages enumerateObjectsUsingBlock:^(BlueshiftInboxMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
                [convertedMessages addObject:[self convertMessageToDictionary:msg]];
            }];
            callback(@{@"messages": [convertedMessages copy]});
        } else {
            callback(@{@"messages":@[]});
        }
    }];
}

- (NSDictionary *)convertMessageToDictionary:(BlueshiftInboxMessage*)message {
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setValue:message.messageUUID forKey:@"messageId"];
    [messageDict setValue:message.messagePayload forKey:@"data"];
    NSString* status = message.readStatus ? @"read" : @"unread";
    [messageDict setValue:status forKey:@"status"];
    double seconds = [message.createdAtDate timeIntervalSince1970];
    NSNumber *timestamp = [NSNumber numberWithInteger: (NSInteger)seconds];
    [messageDict setValue:timestamp forKey:@"createdAt"];
    [messageDict setValue:message.title forKey:@"title"];
    [messageDict setValue:message.detail forKey:@"details"];
    [messageDict setValue:message.objectId.URIRepresentation.absoluteString forKey:@"objectId"];
    NSString *imageUrl = [message.iconImageURL isEqualToString:@""]? nil : message.iconImageURL;
    [messageDict setValue:imageUrl forKey:@"imageUrl"];
    return [messageDict copy];
}

- (BlueshiftInboxMessage*)convertDictionaryToMessage:(NSDictionary *)messageDict {
    BlueshiftInboxMessage* message = [[BlueshiftInboxMessage alloc] init];
    message.messageUUID = [messageDict valueForKey:@"messageId"];
    NSDictionary* data = [messageDict valueForKey:@"data"];
    message.messagePayload = [data copy];
    message.inAppNotificationType = [[[data valueForKey:@"data"] valueForKey:@"inapp"] valueForKey:@"type"];
    NSString* urlString = [messageDict valueForKey:@"objectId"];
    if (urlString && ![urlString isEqualToString:@""]) {
        NSURL* url = [NSURL URLWithString:urlString];
        if (url) {
            message.objectId = [BlueShift.sharedInstance.appDelegate.inboxMOContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
        }
    }
    return message;
}

-(void)showInboxMessage:(FlutterMethodCall*)call {
    NSDictionary *message = call.arguments[@"message"];

    if ([message isKindOfClass:[NSDictionary class]]) {
        [BlueshiftInboxManager showNotificationForInboxMessage:[self convertDictionaryToMessage:message] inboxInAppDelegate:nil];
    }
}

-(void)deleteInboxMessage:(FlutterMethodCall*)call callback:(FlutterResult)callback {
    NSDictionary *message = call.arguments[@"message"];

    if ([message isKindOfClass:[NSDictionary class]]) {
        [BlueshiftInboxManager deleteInboxMessage:[self convertDictionaryToMessage:message] completionHandler:^(BOOL status, NSString * _Nullable errMsg) {
            if (status) {
                callback([NSNumber numberWithBool:YES]);
            } else {
                FlutterError *error = [FlutterError errorWithCode:@"error" message:errMsg details:nil];
                callback(error);
            }
        }];
    }
}

#pragma mark Setters
- (void)setUserInfoEmailId:(FlutterMethodCall*)call {
    NSString *emailId = call.arguments[@"emailId"];

    if ([emailId isKindOfClass:[NSString class]]) {
        [[BlueShiftUserInfo sharedInstance] setEmail:emailId];
        [[BlueShiftUserInfo sharedInstance] save];
    }
}

- (void)setUserInfoCustomerId:(FlutterMethodCall*)call {
    NSString *customerId = call.arguments[@"customerId"];

    if ([customerId isKindOfClass:[NSString class]]) {
        [[BlueShiftUserInfo sharedInstance] setRetailerCustomerID:customerId];
        [[BlueShiftUserInfo sharedInstance] save];
    }
}

- (void)setUserInfoExtras:(FlutterMethodCall*)call {
    NSDictionary *extras = call.arguments[@"extras"];

    if ([extras isKindOfClass:[NSDictionary class]]) {
        [[BlueShiftUserInfo sharedInstance] setExtras:[extras mutableCopy]];
        [[BlueShiftUserInfo sharedInstance] save];
    }
}

- (void)setUserInfoFirstName:(FlutterMethodCall*)call {
    NSString *firstName = call.arguments[@"firstName"];

    if ([firstName isKindOfClass:[NSString class]]) {
        [[BlueShiftUserInfo sharedInstance] setFirstName:firstName];
        [[BlueShiftUserInfo sharedInstance] save];
    }
}

- (void)setUserInfoLastName:(FlutterMethodCall*)call {
    NSString *lastName = call.arguments[@"lastName"];

    if ([lastName isKindOfClass:[NSString class]]) {
        [[BlueShiftUserInfo sharedInstance] setLastName:lastName];
        [[BlueShiftUserInfo sharedInstance] save];
    }
}

- (void)removeUserInfo {
    [BlueShiftUserInfo removeCurrentUserInfo];
}

- (void)resetDeviceId {
    [[BlueShiftDeviceData currentDeviceData] resetDeviceUUID];
}

- (void)setEnablePush:(FlutterMethodCall*)call {
    NSNumber* isEnabled = (NSNumber*)call.arguments[@"isEnabled"];
    [[BlueShiftAppData currentAppData] setEnablePush:isEnabled.boolValue];
    
}

- (void)setEnableInApp:(FlutterMethodCall*)call {
    NSNumber* isEnabled = (NSNumber*)call.arguments[@"isEnabled"];
    [[BlueShiftAppData currentAppData] setEnableInApp:isEnabled.boolValue];
}

- (void)setEnableTracking:(FlutterMethodCall*)call {
    NSNumber* isEnabled = (NSNumber*)call.arguments[@"isEnabled"];
    [[BlueShift sharedInstance] enableTracking:isEnabled.boolValue];
}

- (void)setIDFA:(FlutterMethodCall*)call {
    NSString *idfaString = call.arguments[@"idfaString"];
    
    if ([idfaString isKindOfClass:[NSString class]]) {
        [[BlueShiftDeviceData currentDeviceData] setDeviceIDFA:idfaString];
    }
}

- (void)setCurrentLocation:(FlutterMethodCall*)call {
    NSNumber *latitude = (NSNumber *) call.arguments[@"latitude"];
    NSNumber *longitude = (NSNumber *) call.arguments[@"longitude"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
    
    [[BlueShiftDeviceData currentDeviceData] setCurrentLocation:location];
}

#pragma mark Getters
- (void)getEnableInAppStatus:(FlutterResult)callback {
    if (callback) {
        BOOL isEnabled = [BlueShiftAppData currentAppData].enableInApp;
        callback(@(isEnabled));
    }
}

- (void)getEnablePushStatus:(FlutterResult)callback {
    if (callback) {
        BOOL isEnabled = [BlueShiftAppData currentAppData].enablePush;
        callback(@(isEnabled));
    }
}

- (void)getEnableTrackingStatus:(FlutterResult)callback {
    if (callback) {
        BOOL isEnabled = [[BlueShift sharedInstance] isTrackingEnabled];
        callback(@(isEnabled));
    }
}

- (void)getUserInfoFirstName:(FlutterResult)callback {
    if (callback) {
        NSString* firstName = [BlueShiftUserInfo sharedInstance].firstName;
        callback(firstName ? firstName : @"");
    }
}

- (void)getUserInfoLastName:(FlutterResult)callback {
    if (callback) {
        NSString* lastName = [BlueShiftUserInfo sharedInstance].lastName;
        callback(lastName ? lastName : @"");
    }
}

- (void)getUserInfoEmailId:(FlutterResult)callback {
    if (callback) {
        NSString* emailId = [BlueShiftUserInfo sharedInstance].email;
        callback(emailId ? emailId : @"");
    }
}

- (void)getUserInfoCustomerId:(FlutterResult)callback {
    if (callback) {
        NSString* customerId = [BlueShiftUserInfo sharedInstance].retailerCustomerID;
        callback(customerId ? customerId : @"");
    }
}

- (void)getUserInfoExtras:(FlutterResult)callback {
    if (callback) {
        NSMutableDictionary* extras = [BlueShiftUserInfo sharedInstance].extras;
        callback(extras ? extras : @{});
    }
}

- (void)getCurrentDeviceId:(FlutterResult)callback  {
    if (callback) {
        NSString* deviceId = [BlueShiftDeviceData currentDeviceData].deviceUUID;
        callback(deviceId ? deviceId : @"");
    }
}

#pragma mark Live content
- (void)getLiveContentByEmail:(FlutterMethodCall*)call callback:(FlutterResult)callback {
    NSString *slot = call.arguments[@"slot"];
    NSDictionary *context = call.arguments[@"context"];

    if ([slot isKindOfClass:[NSString class]]) {
        if(![context isKindOfClass:[NSDictionary class]]) {
            context = nil;
        }
        [BlueShiftLiveContent fetchLiveContentByEmail:slot withContext:context success:^(NSDictionary *result) {
            if (callback) {
                callback(result);
            }
        } failure:^(NSError *error) {
            if (callback) {
                callback(@{});
            }
        }];
    } else {
        callback(@{});
    }
}

- (void)getLiveContentByCustomerId:(FlutterMethodCall*)call callback:(FlutterResult)callback {
    NSString *slot = call.arguments[@"slot"];
    NSDictionary *context = call.arguments[@"context"];
    
    if ([slot isKindOfClass:[NSString class]]) {
        if(![context isKindOfClass:[NSDictionary class]]) {
            context = nil;
        }   
        [BlueShiftLiveContent fetchLiveContentByCustomerID:slot withContext:context success:^(NSDictionary *result) {
            if (callback) {
                callback(result);
            }
        } failure:^(NSError *error) {
            if (callback) {
                callback(@{});
            }
        }];
    } else {
        callback(@{});
    }
}

- (void)getLiveContentByDeviceId:(FlutterMethodCall*)call callback:(FlutterResult)callback {
    NSString *slot = call.arguments[@"slot"];
    NSDictionary *context = call.arguments[@"context"];
    
    if ([slot isKindOfClass:[NSString class]]) {
        if(![context isKindOfClass:[NSDictionary class]]) {
            context = nil;
        }
        [BlueShiftLiveContent fetchLiveContentByDeviceID:slot withContext:context success:^(NSDictionary *result) {
            if (callback) {
                callback(result);
            }
        } failure:^(NSError *error) {
            if (callback) {
                callback(@{});
            }
        }];
    } else {
        callback(@{});
    }
}

#pragma mark - Helper methods
- (NSDictionary *)addFLSDKVersionString: (NSDictionary*) details {
    NSString *sdkVersion = [NSString stringWithFormat:@"%@-FL-%@",kBlueshiftSDKVersion,kBlueshiftFlutterSDKVersion];
    if ([details isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [details mutableCopy];
        dict[kInAppNotificationModalSDKVersionKey] = sdkVersion;
        return dict;
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[kInAppNotificationModalSDKVersionKey] = sdkVersion;
        return dict;
    }
}

@end

@implementation BlueshiftStreamHandler {
    FlutterEventSink _Nullable _eventSink;
    NSString  * _Nullable _event;
}

-(void)sendData:(NSString *)event {
    if (_eventSink == nil) {
        _event = event;
    } else {
        _eventSink(event);
    }
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    if (_event) {
        [self sendData:_event];
        _event = nil;
    }
    return nil;
}

@end
