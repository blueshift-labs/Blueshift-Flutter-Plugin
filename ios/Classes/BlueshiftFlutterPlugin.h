#import <Flutter/Flutter.h>

#define kScreenViewed @"screen_viewed"
#define kBlueshiftFlutterSDKVersion @"0.0.2-beta"
#define kBlueshiftEventChannel          @"blueshift/deeplink_event"
#define kBlueshiftMethodChannel         @"blueshift/methods"

@interface BlueshiftFlutterPlugin : NSObject<FlutterPlugin>

@end

@interface DeeplinkStreamHandler: NSObject<FlutterStreamHandler>
- (void)sendDeepLink:(NSString *)url;
@end
