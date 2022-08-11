//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by Ketan Shikhare on 30/06/22.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appGroupID = @"group.blueshift.reads";
}

- (void)didReceiveNotification:(UNNotification *)notification {
    if([self isBlueShiftCarouselPushNotification:notification]) {
        [self showCarouselForNotfication:notification];
    } else {
         //handle notifications if not from Blueshift
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    //Place following codes after your code lines
    if([self isBlueShiftCarouselActions:response]) {
        [self setCarouselActionsForResponse:response completionHandler:^(UNNotificationContentExtensionResponseOption option) {
            completion(option);
        }];
    } else {
        //handle action if not from Blueshift
    }
}
@end
