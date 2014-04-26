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

@class UserEventLocation;

@interface User : PFUser<PFSubclassing>
@property (retain) NSString *name;
@property (retain) NSString *facebookID;
@property (retain) NSNumber *allowAutomaticCheckin;
@property (nonatomic, strong) NSArray *checkins;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isLoggedIn;
- (void)requestFacebookProfileWithCompletion:(void (^)(NSError *error))block;
- (NSURL *)avatarURL;

+ (void)logInWithCompletion:(void (^)(User *user, NSError *error))block;
+ (User *)currentUser;
+ (NSURL *)avatarURL:(NSString *)facebookID;
+ (void)findUserWithFacebookID:(NSString *)facebookID completion:(void (^)(User *user, NSError *error))block;

@end
