//
//  User.m
//  Evently
//
//  Created by Anna Do on 4/2/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "User.h"
#import "EventCheckin.h"
#import <Parse/PFObject+Subclass.h>

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@implementation User

+ (User *)currentUser
{
    return (User *)[PFUser currentUser];
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
            block(nil, error);
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [[User currentUser] requestFacebookProfileWithCompletion:^(NSError *error) {
                block([User currentUser], error);
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
            }];
        } else {
            NSLog(@"User with facebook logged in!");
            [[User currentUser] requestFacebookProfileWithCompletion:^(NSError *error) {
                block([User currentUser], error);
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
            }];
        }
    }];
}

- (void)requestFacebookProfileWithCompletion:(void (^)(NSError *error))block
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            // NSLog(@"userData: %@", userData);
            
            self[@"name"] = userData[@"name"];
            self[@"facebookID"] = userData[@"id"];
            [self saveInBackground];
        }
        block(error);
    }];
}

- (NSURL *)avatarURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self[@"facebookID"]]];
}

- (void)getCheckinForEvent:(Event *)event completion:(void (^)(EventCheckin *checkin, NSError *error))block
{
    PFQuery *query = [EventCheckin query];
    [query whereKey:@"user" equalTo:self];
    [query whereKey:@"event_facebook_id" equalTo:event.facebookID];
    
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

+ (void)logOut
{
    [super logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];

}

+ (User *)userWithDictionary:(NSDictionary *)dictionary {
    User *user = [[User alloc] init];
    user[@"name"] = dictionary[@"name"];
    user[@"facebookID"] = dictionary[@"id"];
    return user;
}

@end
