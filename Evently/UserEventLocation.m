//
//  UserEventLocation.m
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserEventLocation.h"
#import <Parse/PFObject+Subclass.h>
#import "LocationMessage.h"

@implementation UserEventLocation

@dynamic eventFacebookID;
@dynamic user;
@dynamic arrivalTime;
@dynamic departureTime;
@dynamic latitude;
@dynamic longitude;
@dynamic locationUpdateTimestamp;

+ (NSString *)parseClassName {
    return @"UserEventLocation";
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

- (NSString *)displayText
{

    NSString *name = self.user.name;
    NSString *when = [NSDateFormatter localizedStringFromDate:self.arrivalTime
                                                    dateStyle:NSDateFormatterNoStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    NSString *text = [NSString stringWithFormat:@"%@ checked in at %@", name, when];
    return text;
}

- (NSString *)displayTextWithoutName
{
    NSString *when = [NSDateFormatter localizedStringFromDate:self.arrivalTime
                                                    dateStyle:NSDateFormatterNoStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    NSString *text = [NSString stringWithFormat:@"checked in at %@", when];
    return text;
}


- (NSString *)displayTextWithEventName:(Event *)event
{
    NSString *name = self.user.name;
    NSString *text = [NSString stringWithFormat:@"%@ checked in to %@", name, event.name];
    return text;
}

- (BOOL)isPresent {
    return self.arrivalTime && !self.departureTime;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

+ (void) user:(User *)user didUpdateLocation:(Event *)event withLatitude:(CGFloat)latitude withLongitude:(CGFloat)longitude {
    // Update pubnub
    LocationMessage *message = [[LocationMessage alloc] initWithUser:[User currentUser] latitude:latitude longitude:longitude];
    [PubNub sendMessage:[message serializeMessage] toChannel:[event locationChannel] compressed:YES];
    
    // Update parse
    NSDate *now = [[NSDate alloc] init];
    [UserEventLocation findOrInitializeForUser:user event:event withCompletion:^(UserEventLocation *userEventLocation, NSError *error) {
        if (error) {
            NSLog(@"Error updating location for event: %@", [error description]);
        } else {
            if (!userEventLocation.locationUpdateTimestamp || [now compare:userEventLocation.locationUpdateTimestamp] == NSOrderedDescending) {
                userEventLocation.locationUpdateTimestamp = now;
                userEventLocation.latitude = latitude;
                userEventLocation.longitude = longitude;
                [userEventLocation saveInBackground];
            }
        }
    }];
}

+ (void) user:(User *)user didArriveAtEvent:(Event *)event withCompletion:(void (^)(NSError *error))block {
    NSDate *now = [[NSDate alloc] init];
    [UserEventLocation findOrInitializeForUser:user event:event withCompletion:^(UserEventLocation *userEventLocation, NSError *error) {
        if (error) {
            block(error);
        } else {
            if (!userEventLocation.arrivalTime) {
                userEventLocation.latitude = event.location.latLon.coordinate.latitude;
                userEventLocation.longitude = event.location.latLon.coordinate.longitude;
                userEventLocation.locationUpdateTimestamp = now;
                userEventLocation.arrivalTime = now;
                [userEventLocation saveInBackground];
            }
        }
    }];
}

+ (void) user:(User *)user didDepartEvent:(Event *)event withCompletion:(void (^)(NSError *error))block {
    NSDate *now = [[NSDate alloc] init];
    [UserEventLocation findOrInitializeForUser:user event:event withCompletion:^(UserEventLocation *userEventLocation, NSError *error) {
        if (error) {
            block(error);
        } else {
            if (!userEventLocation.departureTime) {
                userEventLocation.departureTime = now;
                [userEventLocation saveInBackground];
            }
        }
    }];
}

+ (void) usersAtEvent:(Event *)event withCompletion:(void (^)(NSArray *users, NSError *error))block {
    if (!event) {
        block(nil, [NSError errorWithDomain:@"Nil event passed to usersAtEvent" code:100 userInfo:nil]);
        return;
    }
    
    NSDate *now = [[NSDate alloc] init];
    
    PFQuery *query = [UserEventLocation query];
    [query whereKey:@"eventFacebookID" equalTo:event.facebookID];
    [query whereKey:@"arrivalTime" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departureTime"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *users = nil;
        if (!error || [error code] == 101) {
            users = [[NSMutableArray alloc] init];
            for (UserEventLocation *userEventLocation in objects) {
                User *user = userEventLocation[@"user"];
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
    
    PFQuery *query = [UserEventLocation query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"arrivalTime" lessThanOrEqualTo:now];
    [query whereKeyDoesNotExist:@"departureTime"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error retrieving event for user: %@", [error description]);
            block(nil, error);
        } else {
            if (object) {
                [Event eventForFacebookID:object[@"eventFacebookID"] withIncludeAttendees:includeAttendees withCompletion:block];
            } else {
                block(nil, nil);
            }
        }
    }];
}

+ (void) findOrInitializeForUser:(User *)user event:(Event *)event withCompletion:(void (^)(UserEventLocation *userEventLocation, NSError *error))block {
    
    PFQuery *query = [UserEventLocation query];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"eventFacebookID" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error retrieving user event locations for user and event: %@", [error description]);
            block(nil, error);
        } else {
            if (object) {
                block((UserEventLocation *)object, nil);
            } else {
                UserEventLocation *userEventLocation = [[UserEventLocation alloc] init];
                userEventLocation.user = user;
                userEventLocation.eventFacebookID = event.facebookID;
                block(userEventLocation, nil);
            }
        }
    }];
}

+ (void) userEventLocationsForEvent:(Event *)event withCompletion:(void (^)(NSArray *userEventLocations, NSError *error))block {
    PFQuery *query = [UserEventLocation query];
    [query whereKey:@"eventFacebookID" equalTo:event.facebookID];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error retrieving user event locations for event: %@", [error description]);
            block(nil, error);
        } else {
            block(objects, nil);
        }
    }];
}

// Cache the user event locations into a PF relation and save
+ (void) user:(User *) user isAtEvent:(Event *)event withCompletion:(void (^)(BOOL isPresent, NSError *error))block {
    [UserEventLocation findOrInitializeForUser:user event:event withCompletion:^(UserEventLocation *userEventLocation, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            block([userEventLocation isPresent], nil);
        }
    }];
}

@end
