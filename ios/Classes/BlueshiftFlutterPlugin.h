#import <Flutter/Flutter.h>

#define kScreenViewed                   @"screen_viewed"
#define kBlueshiftFlutterSDKVersion     @"1.1.2"
#define kBlueshiftDeepLinkChannel       @"blueshift/deeplink_event"
#define kBlueshiftInboxEventChannel     @"blueshift/inbox_event"
#define kBlueshiftPushClickChannel      @"blueshift/push_click_event"
#define kBlueshiftMethodChannel         @"blueshift/methods"

@interface BlueshiftFlutterPlugin : NSObject<FlutterPlugin>

@end
