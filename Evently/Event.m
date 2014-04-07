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
           withStatus:(NSInteger)queryStatus
         onCompletion:(void (^)(NSArray *events, NSError *error))block {
    
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    NSMutableSet *pendingRequests = [[NSMutableSet alloc] init];
    
    for (NSInteger i = 0; i < sizeof(AttendanceStatuses) / sizeof(AttendanceYes); i++) {

        NSInteger attendanceStatus = AttendanceStatuses[i];
        if ((queryStatus & attendanceStatus) > 0) {
            NSString *path = [NSString stringWithFormat:@"/%@/events/%@?fields=id,cover,description,end_time,location,name,start_time,venue,rsvp_status", user[@"facebookID"], [Event suffixForStatus:attendanceStatus]];
            
            FBRequest *request = [FBRequest requestForGraphPath:path];
            [pendingRequests addObject:request];
            
            [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSMutableArray *events = [[NSMutableArray alloc] init];
                
                if (!error) {
                    for (NSDictionary *dictionary in result[@"data"]) {
                        Event *event = [Event eventWithDictionary:dictionary];
                        [events addObject:event];
                    }
                } else {
                    NSLog(@"Error requesting events: %@", [error description]);
                }
                
                // critical section
                [lock lock];
                [allEvents addObjectsFromArray:events];
                [pendingRequests removeObject:request];
                [lock unlock];
                
                if ([pendingRequests count] == 0) {
                    NSLog(@"Returning events: %@", allEvents);
                    block(allEvents, error);
                }
            }];
        }
    }
    
    [connection start];
}

+ (Event *)eventWithDictionary:(NSDictionary *)dictionary {
    Event *event = [[Event alloc] init];
    
    event.location = [Location locationWithDictionary:dictionary];
    event.location.name = dictionary[@"location"];

    event.facebookID = dictionary[@"id"];
    event.name = dictionary[@"name"];
    event.description = dictionary[@"description"];
    event.coverPhotoURL = dictionary[@"cover"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    event.startTime = [formatter dateFromString:dictionary[@"start_time"]];
    event.endTime = [formatter dateFromString:dictionary[@"end_time"]];
    event.userAttendanceStatus = [Event attendanceStatusForRsvpString:dictionary[@"rsvp_status"]];
    
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
         
+ (NSInteger)attendanceStatusForRsvpString:(NSString *)rsvpString {
    if ([rsvpString isEqualToString:@"attending"]) {
        return AttendanceYes;
    } else if ([rsvpString isEqualToString:@"maybe"]) {
        return AttendanceMaybe;
    } else if ([rsvpString isEqualToString:@"declined"]) {
        return AttendanceNo;
    } else if ([rsvpString isEqualToString:@"not_replied"]) {
        return AttendanceNotReplied;
    } else {
        NSLog(@"Invalid rsvpString: %@", rsvpString);
        return -1;
    }
}

@end
