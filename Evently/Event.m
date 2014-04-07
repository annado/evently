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
           withIncludeAttendees:(BOOL)includeAttendees
           withCompletion:(void (^)(NSArray *events, NSError *error))block {
    
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    NSMutableSet *pendingEventRequests = [[NSMutableSet alloc] init];
    
    for (NSInteger i = 0; i < sizeof(AttendanceStatuses) / sizeof(AttendanceYes); i++) {
        
        NSInteger attendanceStatus = AttendanceStatuses[i];
        if ((queryStatus & attendanceStatus) > 0) {

            NSString *path = [NSString stringWithFormat:@"/%@/events/%@?fields=id,cover,description,end_time,location,name,start_time,venue,rsvp_status", user[@"facebookID"], [Event suffixForStatus:attendanceStatus]];
            
            FBRequest *eventRequest = [FBRequest requestForGraphPath:path];
            [pendingEventRequests addObject:eventRequest];
            
            [connection addRequest:eventRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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
                [pendingEventRequests removeObject:eventRequest];
                [lock unlock];
                
                if ([pendingEventRequests count] == 0) {
                    
                    if (includeAttendees) {
                        [Event fillAttendees:allEvents onCompletion:^(NSArray *events, NSError *error) {
                            block(events, error);
                        }];
                    } else {
                        block(events, error);
                    }
                }
            }];
        }
    }
    
    [connection start];
}

+ (void)fillAttendees:(NSArray *)events onCompletion:(void (^)(NSArray *events, NSError *error))block {
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    NSMutableSet *pendingGuestRequests = [[NSMutableSet alloc] init];
    
    for (Event *event in events) {
        
        NSString *path = [NSString stringWithFormat:@"%@/invited", event.facebookID];
        FBRequest *guestRequest = [FBRequest requestForGraphPath:path];
        [pendingGuestRequests addObject:guestRequest];
        
        [connection addRequest:guestRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error) {
                for (NSDictionary *dictionary in result[@"data"]) {
                    User *user = [User userWithDictionary:dictionary];
                    NSString *status = dictionary[@"rsvp_status"];
                    if ([status isEqualToString:@"attending"]) {
                        [event.attendingUsers addObject:user];
                    } else if ([status isEqualToString:@"unsure"]) {
                        [event.unsureUsers addObject:user];
                    } else if ([status isEqualToString:@"declined"]) {
                        [event.declinedUsers addObject:user];
                    } else if ([status isEqualToString:@"not_replied"]) {
                        [event.notRepliedUsers addObject:user];
                    } else {
                        NSLog(@"Invalid rsvpStatus: %@", status);
                    }
                }
            } else {
                NSLog(@"Error requesting attendees: %@", [error description]);
            }
            
            [lock lock];
            [pendingGuestRequests removeObject:guestRequest];
            [lock unlock];
            
            if ([pendingGuestRequests count] == 0) {
                block(events, error);
            }
        }];

    }
    
    [connection start];
}

+ (void)eventForFacebookID:(NSString *)facebookID withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block {
    
    NSString *path = [NSString stringWithFormat:@"/%@?fields=id,cover,description,end_time,location,name,start_time,venue", facebookID];
    
    [FBRequestConnection startWithGraphPath:path completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            Event *event = [Event eventWithDictionary:result];
            if (includeAttendees) {
                [Event fillAttendees:@[event] onCompletion:^(NSArray *events, NSError *error) {
                    if (!error) {
                        block(events[0], error);
                    } else {
                        block(nil, error);
                    }
                }];
            } else {
                block(event, error);
            }
        } else {
            NSLog(@"Error requesting events: %@", [error description]);
            block(nil, error);
        }
    }];
    
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
    
    if (dictionary[@"rsvp_status"]) {
        event.userAttendanceStatus = [Event attendanceStatusForRsvpString:dictionary[@"rsvp_status"]];
    }
    event.attendingUsers = [[NSMutableArray alloc] init];
    event.unsureUsers = [[NSMutableArray alloc] init];
    event.declinedUsers = [[NSMutableArray alloc] init];
    event.notRepliedUsers = [[NSMutableArray alloc] init];
    
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
