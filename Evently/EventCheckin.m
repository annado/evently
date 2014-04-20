//
//  EventCheckin.m
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventCheckin.h"
#import <Parse/PFObject+Subclass.h>

@implementation EventCheckin

@dynamic eventFacebookID;
@dynamic user;
@dynamic arrivalTime;
@dynamic departureTime;

+ (NSString *)parseClassName {
    return @"EventCheckin";
}

- (id)initWithUser:(User *)user forEvent:(Event *)event
{
    self = [super init];
    if (self) {
        self.user = user;
        self.eventFacebookID = event.facebookID;
        self.arrivalTime = [[NSDate alloc] init];
        [self saveInBackground];
    }
    return self;
}

// TODO call didDepartEvent on previous event?
// TODO idempotent checkin?
// TODO allow checking back into an event?
+ (void) user:(User *)user didArriveAtEvent:(Event *)event withCompletion:(void (^)(NSError *error))block {
    if (!event) {
        block([NSError errorWithDomain:@"Nil event passed to didDepartEvent" code:100 userInfo:nil]);
        return;
    }
    
    // Check user into current event
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error marking arrival: %@", [error description]);
            block(error);
        } else {
            if (!object) {
                [user checkinForEvent:event];
            }
            block(nil);
        }
    }];
}

+ (void) user:(User *)user didDepartEvent:(Event *)event withCompletion:(void (^)(NSError *error))block {
    if (!event) {
        block([NSError errorWithDomain:@"Nil event passed to didDepartEvent" code:100 userInfo:nil]);
        return;
    }
    
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error marking departure: %@", [error description]);
            block(error);
        } else {
            if (object) {
                object[@"departure_time"] = now;
                [object saveInBackground];
            }
            block(nil);
        }
    }];
}

+ (void) usersAtEvent:(Event *)event withCompletion:(void (^)(NSArray *users, NSError *error))block {
    if (!event) {
        block(nil, [NSError errorWithDomain:@"Nil event passed to usersAtEvent" code:100 userInfo:nil]);
        return;
    }
    
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    [query whereKey:@"arrival_time" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departure_time"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *users = nil;
        if (!error || [error code] == 101) {
            users = [[NSMutableArray alloc] init];
            for (EventCheckin *checkin in objects) {
                User *user = checkin[@"user"];
                [users addObject:user];
            }
        } else {
            NSLog(@"Error retrieving users at event: %@", [error description]);
        }
        block(users, error);
    }];
}

+ (void) checkinsForEvent:(Event *)event withCompletion:(void (^)(NSArray *checkins, NSError *error))block {
    if (!event) {
        block(nil, [NSError errorWithDomain:@"Nil event passed to checkinsForEvent" code:100 userInfo:nil]);
        return;
    }
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error || [error code] == 101) {
        } else {
            NSLog(@"Error retrieving users at event: %@", [error description]);
        }
        block(objects, error);
    }];
}

+ (void) currentEventForUser:(User *)user withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block {
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"arrival_time" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departure_time"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error retrieving event for user: %@", [error description]);
            block(nil, error);
        } else {
            if (object) {
                [Event eventForFacebookID:object[@"event_facebook_id"] withIncludeAttendees:includeAttendees withCompletion:block];
            } else {
                block(nil, nil);
            }
        }
    }];
}

@end
