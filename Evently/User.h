//
//  User.h
//  Evently
//
//  Created by Anna Do on 4/2/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : PFUser<PFSubclassing>
+ (void)logInWithCompletion:(void (^)(User *user, NSError *error))block;
- (BOOL)isLoggedIn;
+ (User *)currentUser;
- (void)requestFacebookProfileWithCompletion:(void (^)(NSError *error))block;
- (NSURL *)avatarURL;
@end
