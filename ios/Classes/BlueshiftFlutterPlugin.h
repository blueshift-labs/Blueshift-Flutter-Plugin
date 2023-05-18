#import <Flutter/Flutter.h>

#define kScreenViewed @"screen_viewed"
#define kBlueshiftFlutterSDKVersion @"1.0.1"
#define kBlueshiftEventChannel          @"blueshift/deeplink_event"
#define kBlueshiftMethodChannel         @"blueshift/methods"

@interface BlueshiftFlutterPlugin : NSObject<FlutterPlugin>

@end

@interface DeeplinkStreamHandler: NSObject<FlutterStreamHandler>
- (void)sendDeepLink:(NSString *)url;
@end
