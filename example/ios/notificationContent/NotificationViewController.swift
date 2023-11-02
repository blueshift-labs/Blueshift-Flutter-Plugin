//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Ketan Shikhare on 02/11/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import BlueShift_iOS_Extension_SDK

class NotificationViewController: BlueShiftCarousalViewController, UNNotificationContentExtension {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appGroupID = "YOUR APP GROUP ID"
    }
    
    func didReceive(_ notification: UNNotification) {
       //Check if notification is from Blueshift
        if isBlueShiftCarouselPush(notification) {
            showCarousel(forNotfication: notification)
        } else {
            //handle notifications if not from Blueshift
        }
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        //Check if the action is from Blueshift carousel
        if isBlueShiftCarouselActions(response) {
            setCarouselActionsFor(response) { (option) in
                completion(option)
            }
        } else {
            //handle action if not from Blueshift
        }
    }
}
