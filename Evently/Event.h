//
//  Event.h
//  Evently
//
//  Created by Ning Liang on 4/5/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Location.h"

extern NSInteger const AttendanceYes;
extern NSInteger const AttendanceMaybe;
extern NSInteger const AttendanceNo;
extern NSInteger const AttendanceNotReplied;
extern NSInteger const AttendanceAll;

@interface Event : NSObject

@property (nonatomic, strong) NSString *facebookID;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *coverPhotoURL;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, strong) NSMutableArray *attendingUsers;
@property (nonatomic, strong) NSMutableArray *unsureUsers;
@property (nonatomic, strong) NSMutableArray *declinedUsers;
@property (nonatomic, strong) NSMutableArray *notRepliedUsers;

// For the currentUser
@property (nonatomic, assign) NSInteger userAttendanceStatus;

+ (void)eventsForUser:(User *)user withStatus:(NSInteger)status withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(NSArray *events, NSError *error))block;
+ (void)eventForFacebookID:(NSString *)facebookID withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))completion;
+ (Event *)eventWithDictionary:(NSDictionary *)dictionary;
@end
