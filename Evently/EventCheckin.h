//
//  EventCheckin.h
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Event.h"

@interface EventCheckin : PFObject <PFSubclassing>

@property (retain) NSString *eventFacebookID;
@property (retain) User *user;
@property (retain) NSDate *arrivalTime;
@property (retain) NSDate *departureTime;

+ (NSString *)parseClassName;
+ (void) user:(User *)user didArriveAtEvent:(Event *)event;
+ (void) user:(User *)user didDepartEvent:(Event *)event;
+ (void) usersAtEvent:(Event *)event withCompletion:(void (^)(NSArray *users, NSError *error))block;
+ (void) currentEventForUser:(User *)user withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block;

@end
