//
//  BlueshiftStreamHandler.h
//  blueshift_plugin
//
//  Created by Ketan Shikhare on 28/08/23.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlueshiftStreamHandler: NSObject<FlutterStreamHandler>
- (void)sendData:(NSDictionary *)data;
- (void)sendEvent:(NSString*)event;

@end


NS_ASSUME_NONNULL_END
