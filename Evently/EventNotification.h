//
//  EventNotifications.h
//  Evently
//
//  Created by Anna Do on 4/20/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventNotification : NSObject
- (id)initWithEvent:(Event *)event;
+ (NSString *)getEventIDForNotification:(UILocalNotification *)notification;
+ (void)handleForegroundLocalNotification:(UILocalNotification *)localNotification;
@end
