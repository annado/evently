//
//  Event.h
//  Evently
//
//  Created by Ning Liang on 4/5/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

extern NSInteger const AttendanceYes;
extern NSInteger const AttendanceMaybe;
extern NSInteger const AttendanceNo;
extern NSInteger const AttendanceNotReplied;
extern NSInteger const AttendanceAll;

@interface Event : NSObject
+ (void)eventsForUser:(User *)user withStatus:(NSInteger)status onCompletion:(void (^)(NSArray *events, NSError *error))block;
+ (Event *)eventWithDictionary:(NSDictionary *)dictionary;
@end
