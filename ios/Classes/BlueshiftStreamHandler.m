//
//  BlueshiftStreamHandler.m
//  blueshift_plugin
//
//  Created by Ketan Shikhare on 28/08/23.
//

#import "BlueshiftStreamHandler.h"

@implementation BlueshiftStreamHandler {
    FlutterEventSink _Nullable _eventSink;
    NSDictionary* _Nullable _data;
    NSString  * _Nullable _event;
}

-(void)sendData:(NSDictionary *)data {
    if (_eventSink == nil) {
        _data = data;
    } else {
        _eventSink(data);
    }
}

-(void)sendEvent:(NSString*)event {
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
    
    //Send cached events/data
    if (_event) {
        [self sendEvent:_event];
        _event = nil;
    }
    if (_data) {
        [self sendData:_data];
        _data = nil;
    }
    return nil;
}

@end
