//
//  Event.m
//  Evently
//
//  Created by Ning Liang on 4/5/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "Event.h"

NSInteger const AttendanceYes = 1;
NSInteger const AttendanceMaybe = 1 << 1;
NSInteger const AttendanceNo = 1 << 2;
NSInteger const AttendanceNotReplied = 1 << 3;
NSInteger const AttendanceAll = AttendanceYes | AttendanceMaybe | AttendanceNo | AttendanceNotReplied;
NSInteger AttendanceStatuses[] = { AttendanceYes, AttendanceMaybe, AttendanceNo, AttendanceNotReplied };

@implementation Event

// TODO properly handle errors
+ (void)eventsForUser:(User *)user
           withStatus:(NSInteger)status
         onCompletion:(void (^)(NSArray *events, NSError *error))block {

    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    
    int pending = 0;
    NSInteger *pendingCount = &pending;
    
    for (NSInteger i = 0; i < sizeof(AttendanceStatuses) / sizeof(AttendanceYes); i++) {
        NSInteger attendanceStatus = AttendanceStatuses[i];
        if ((status & attendanceStatus) > 0) {
            NSString *path = [NSString stringWithFormat:@"/%@/events/%@", user[@"facebookID"], [Event suffixForStatus:attendanceStatus]];
            
            *pendingCount += 1;
            [FBRequestConnection startWithGraphPath:path completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error) {
                    NSMutableArray *events = [[NSMutableArray alloc] init];
                    for (NSDictionary *dictionary in result[@"data"]) {
                        Event *event = [Event eventWithDictionary:dictionary];
                        
                        // critical section
                        [lock lock];
                        [events addObject:event];
                        [lock unlock];
                    }
                } else {
                    NSLog(@"Error requesting events: %@", [error description]);
                }
                
                // critical section
                [lock lock];
                *pendingCount -= 1;
                [lock unlock];
                
                if (*pendingCount == 0) {
                    block(allEvents, error);
                }
            }];
        }
    }
}

+ (Event *)eventWithDictionary:(NSDictionary *)dictionary {
    Event *event = [[Event alloc] init];
    
    // TODO parse the fields from the JSON
    
    return event;
}

+ (NSString *)suffixForStatus:(NSInteger)status {
    switch (status) {
        case AttendanceYes: return @"attending";
        case AttendanceMaybe: return @"maybe";
        case AttendanceNo: return @"declined";
        case AttendanceNotReplied: return @"not_replied";
        default:
            NSLog(@"Invalid status: %d", status);
            return nil;
    }
}

@end
