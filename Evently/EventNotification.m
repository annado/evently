//
//  EventNotifications.m
//  Evently
//
//  Created by Anna Do on 4/20/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "DateHelper.h"
#import "EventNotification.h"
#import "CRToast.h"

@interface EventNotification ()
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) UILocalNotification *notification;
@end

@implementation EventNotification

static const NSString *EventIDKey = @"event.facebookID";

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
    if ([self localNotificationExists]) {
        return;
    }
    
    NSDate *itemDate = _event.isDateOnly ? _event.date : _event.startTime;

    if (!itemDate || [DateHelper dateIsOlderThanNow:itemDate]) {
        return;
    }
    
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
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:_event.facebookID forKey:EventIDKey];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    self.notification = localNotif;
}

- (BOOL)localNotificationExists
{
    NSArray *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger i = [scheduledLocalNotifications indexOfObjectPassingTest:^BOOL(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
        return [_event.facebookID isEqualToString:localNotification.userInfo[EventIDKey]];
    }];
    
    return (i != NSNotFound);
}

+ (NSString *)getEventIDForNotification:(UILocalNotification *)notification
{
    return notification.userInfo[EventIDKey];
}

+ (void)handleForegroundLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *options = @{
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastTextKey : notification.alertBody,
                              kCRToastBackgroundColorKey : [UIColor orangeColor],
                              kCRToastTimeIntervalKey : @(10),
                              kCRToastFontKey : [UIFont fontWithName:@"HelveticaNeue-Light" size:17],
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastInteractionRespondersKey : @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeSwipe
                                                     automaticallyDismiss:NO
                                                                    block:^(CRToastInteractionType interactionType){
                                                                        [CRToastManager dismissNotification:YES];
                                                                    }],
                                                                   [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                   automaticallyDismiss:NO
                                                                  block:^(CRToastInteractionType interactionType){
                                                                      NSLog(@"TODO: go to event page from toast (%@)", NSStringFromCRToastInteractionType(interactionType));
                                                                      if (interactionType == CRToastInteractionTypeSwipeUp) {
                                                                          [CRToastManager dismissNotification:YES];
                                                                      } else {
                                                                      }

                                                                  }]
                                                                   ]
                              };
    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}
@end
