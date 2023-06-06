#import <Flutter/Flutter.h>

#define kScreenViewed @"screen_viewed"
#define kBlueshiftFlutterSDKVersion @"1.0.1"
#define kBlueshiftDeepLinkChannel       @"blueshift/deeplink_event"
#define kBlueshiftInboxEventChannel     @"blueshift/inbox_event"
#define kBlueshiftMethodChannel         @"blueshift/methods"

@interface BlueshiftFlutterPlugin : NSObject<FlutterPlugin>

@end

@interface BlueshiftStreamHandler: NSObject<FlutterStreamHandler>
- (void)sendData:(NSString *)event;
@end
