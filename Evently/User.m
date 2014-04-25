//
//  User.m
//  Evently
//
//  Created by Anna Do on 4/2/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "User.h"
#import "EventCheckin.h"
#import "EventNotification.h"
#import <Parse/PFObject+Subclass.h>

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@implementation User

@dynamic name;
@dynamic facebookID;
@dynamic allowAutomaticCheckin;
@synthesize checkins;

+ (User *)currentUser
{
    return (User *)[PFUser currentUser];
}

+ (void)findUserWithFacebookID:(NSString *)facebookID completion:(void (^)(User *user, NSError *error))block
{
    PFQuery *query = [User query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query whereKey:@"facebookID" equalTo:facebookID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            block((User *)object, error);
        }
    }];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.facebookID = dictionary[@"id"];
        self.allowAutomaticCheckin = [NSNumber numberWithBool:NO];
    }
    return self;
}

- (BOOL)isLoggedIn
{
    return [User currentUser] && // Check if a user is cached
    [PFFacebookUtils isLinkedWithUser:[User currentUser]];
}

+ (void)logInWithCompletion:(void (^)(User *user, NSError *error))block
{
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"email", @"user_about_me", @"user_location", @"user_events", @"rsvp_event"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            // callback used only for error case
            NSLog(@"Login failed: %@", error);
            block(nil, error);
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [[User currentUser] requestFacebookProfileWithCompletion:^(NSError *error) {
                block([User currentUser], error);
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
            }];
        } else {
            NSLog(@"User with facebook logged in!");
            [[User currentUser] fetchCheckins];
            [[User currentUser] requestFacebookProfileWithCompletion:^(NSError *error) {
                block([User currentUser], error);
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
            }];
        }
    }];
}

- (void)fetchCheckins
{
    PFRelation *relation = [self relationForKey:@"checkins"];
    
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
            NSLog(@"Failed to query checkins");
        } else {
            self.checkins = objects;
        }
    }];

}

- (void)requestFacebookProfileWithCompletion:(void (^)(NSError *error))block
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            self[@"name"] = userData[@"name"];
            self[@"facebookID"] = userData[@"id"];
            [self saveInBackground];
        }
        block(error);
    }];
}

- (NSURL *)avatarURL
{
    return [User avatarURL:self[@"facebookID"]];
}

- (void)getCheckinForEvent:(Event *)event completion:(void (^)(EventCheckin *checkin, NSError *error))block
{
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:self];
    [query whereKey:@"eventFacebookID" equalTo:event.facebookID];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error && [error code] != 101) {
            NSLog(@"Error retrieving event for user: %@", [error description]);
            block(nil, error);
        } else {
            if (object) {
                block((EventCheckin *)object, error);
            } else {
                block(nil, nil);
            }
        }
    }];
}

- (EventCheckin *)checkinForEvent:(Event *)event
{
    EventCheckin *checkin = [[EventCheckin alloc] initWithUser:self forEvent:event];

    [checkin saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFRelation *relation = [self relationForKey:@"checkins"];
        [relation addObject:checkin];
        [self saveInBackground];
        [EventNotification sendPushNotificationForCheckin:checkin toEvent:event];
    }];
    return checkin;
}

- (BOOL)isCheckedInToEvent:(Event *)event
{
    // Assumes currentUser (for now)
    if (self.checkins) {
        return [self isCheckedInToEvent:event forCheckins:self.checkins];
    } else {
        return NO;
    }
}

// TODO: this is ugly
- (BOOL)isCheckedInToEvent:(Event *)event forCheckins:(NSArray *)checkins
{
    NSString *eventID = event.facebookID;
    NSUInteger i = [self.checkins indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [eventID isEqualToString:obj[@"eventFacebookID"]];
    }];
    return (i != NSNotFound);
}

+ (void)logOut
{
    [super logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

+ (NSURL *)avatarURL:(NSString *)facebookID {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

}

@end
