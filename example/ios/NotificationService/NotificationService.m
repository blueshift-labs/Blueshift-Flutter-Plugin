//
//  NotificationService.m
//  NotificationService
//
//  Created by Ketan Shikhare on 30/06/22.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here.
    if([[BlueShiftPushNotification sharedInstance] isBlueShiftPushNotification:request]) {
        self.bestAttemptContent.attachments = [[BlueShiftPushNotification sharedInstance] integratePushNotificationWithMediaAttachementsForRequest:request andAppGroupID:nil];
    } else {
        //handle notifications if not from Blueshift
    }
    
   self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    
    // Called just before the extension will be terminated by the system.
    if([[BlueShiftPushNotification sharedInstance] hasBlueShiftAttachments]) {
        self.bestAttemptContent.attachments = [BlueShiftPushNotification sharedInstance].attachments;
    }
    self.contentHandler(self.bestAttemptContent);
}

@end
