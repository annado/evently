//
//  User.m
//  Evently
//
//  Created by Anna Do on 4/2/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "User.h"
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

+ (void)logInWithFacebook
{
    [PFFacebookUtils initializeFacebook];
    
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:[NSString stringWithFormat:@"Uh oh. An error occurred: %@", error]
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                });
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
        } else {
            NSLog(@"User with facebook logged in!");
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
        }
    }];
}

+ (void)logOut
{
    [super logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];

}

@end
