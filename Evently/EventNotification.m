//
//  EventNotifications.m
//  Evently
//
//  Created by Anna Do on 4/20/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventNotification.h"

@interface EventNotification ()
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) UILocalNotification *notification;
@end

@implementation EventNotification

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        [self scheduleLocalNotification];
    }
    return self;
}

- (void)scheduleLocalNotification
{
    NSDate *itemDate = _event.isDateOnly ? _event.date : _event.startTime;
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
        return;
    }
    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(60*60)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"%@ starts in an hour.",
                            _event.name];
    localNotif.alertAction = NSLocalizedString(@"View Event", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:_event.facebookID forKey:@"EventID"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    self.notification = localNotif;
}

@end
