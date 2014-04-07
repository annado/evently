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

+ (void) user:(User *)user didArriveAtEvent:(Event *)event {
    NSDate *now = [[NSDate alloc] init];

    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error marking arrival: %@", [error description]);
            return;
        }
        
        if (!object) {
            object = [[EventCheckin alloc] init];
            object[@"user"] = user;
            object[@"event_facebook_id"] = event.facebookID;
            object[@"arrival_time"] = now;
            [object saveInBackground];
        }
    }];
}

+ (void) user:(User *)user didDepartEvent:(Event *)event {
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error marking departure: %@", [error description]);
            return;
        }
        
        if (object) {
            object[@"departure_time"] = now;
            [object saveInBackground];
        }
    }];
}

+ (void) usersAtEvent:(Event *)event withCompletion:(void (^)(NSArray *users, NSError *error))block {
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    [query whereKey:@"arrival_time" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departure_time"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *users = nil;
        if (!error) {
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

+ (void) currentEventForUser:(User *)user withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block {
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"arrival_time" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departure_time"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            [Event eventForFacebookID:object[@"event_facebook_id"] withIncludeAttendees:includeAttendees withCompletion:block];
        } else {
            NSLog(@"Error retrieving event for user: %@", [error description]);
            block(nil, error);
        }
    }];
}


@end
;