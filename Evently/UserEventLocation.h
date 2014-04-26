//
//  UserEventLocation.h
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Event.h"

@interface UserEventLocation : PFObject <PFSubclassing>

@property (retain) NSString *eventFacebookID;
@property (retain) User *user;
@property (retain) NSDate *arrivalTime;
@property (retain) NSDate *departureTime;

@property (assign) CGFloat latitude;
@property (assign) CGFloat longitude;
@property (assign) NSDate *locationUpdateTimestamp;

+ (NSString *)parseClassName;

- (id)initWithUser:(User *)user forEvent:(Event *)event;
- (NSString *)displayText;
- (NSString *)displayTextWithEventName:(Event *)event;
- (NSString *)displayTextWithoutName;
- (BOOL)isPresent;
- (CLLocationCoordinate2D)coordinate;

// Fetch user locations / for event
+ (void) userEventLocationsForEvent:(Event *)event withCompletion:(void (^)(NSArray *userEventLocations, NSError *error))block;

// Arrival / departure
+ (void) user:(User *)user didArriveAtEvent:(Event *)event withCompletion:(void (^)(NSError *error))block;
+ (void) user:(User *)user didDepartEvent:(Event *)event withCompletion:(void (^)(NSError *error))block;
+ (void) usersAtEvent:(Event *)event withCompletion:(void (^)(NSArray *users, NSError *error))block;
+ (void) currentEventForUser:(User *)user withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block;
+ (void) user:(User *) user isAtEvent:(Event *)event withCompletion:(void (^)(BOOL isPresent, NSError *error))block;

// Updating location
+ (void) user:(User *)user didUpdateLocation:(Event *)event withLatitude:(CGFloat)latitude withLongitude:(CGFloat)longitude;

@end
