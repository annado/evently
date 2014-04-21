//
//  Event.h
//  Evently
//
//  Created by Ning Liang on 4/5/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

typedef enum {
    EventAttendanceYes = 1,
    EventAttendanceMaybe = 1 << 1,
    EventAttendanceNo = 1 << 2,
    EventAttendanceNotReplied = 1 << 3,
    EventAttendanceAll = EventAttendanceYes | EventAttendanceMaybe | EventAttendanceNo | EventAttendanceNotReplied
} EventAttendance;

@class User;

@interface Event : NSObject

@property (nonatomic, strong) NSString *facebookID;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSURL *coverPhotoURL;
@property (nonatomic, strong) Location *location;
@property (nonatomic, assign) BOOL isDateOnly;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, assign) BOOL isHappeningNow;

@property (nonatomic, strong) NSMutableArray *attendingUsers;
@property (nonatomic, strong) NSMutableArray *unsureUsers;
@property (nonatomic, strong) NSMutableArray *declinedUsers;
@property (nonatomic, strong) NSMutableArray *notRepliedUsers;

// For the currentUser
@property (nonatomic, assign) NSInteger userAttendanceStatus;
@property (nonatomic, readonly, strong) NSString *displayUserAttendanceStatus;

+ (void)eventsForUser:(User *)user withStatus:(NSInteger)status withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(NSArray *events, NSError *error))block;
+ (void)eventForFacebookID:(NSString *)facebookID withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))completion;
+ (void)addGeofencesForEvents:(NSArray *)events;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)displayDate;
- (void)checkinCurrentUser;

@end
