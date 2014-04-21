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

@class EventCheckin;

@interface User : PFUser<PFSubclassing>
@property (retain) NSString *name;
@property (retain) NSString *facebookID;
@property (retain) NSNumber *allowAutomaticCheckin;
@property (nonatomic, strong) NSArray *checkins;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isLoggedIn;
- (void)requestFacebookProfileWithCompletion:(void (^)(NSError *error))block;
- (NSURL *)avatarURL;
- (EventCheckin *)checkinForEvent:(Event *)event;
- (void)getCheckinForEvent:(Event *)event completion:(void (^)(EventCheckin *checkin, NSError *error))block;
- (BOOL)isCheckedInToEvent:(Event *)event;
- (BOOL)isCheckedInToEvent:(Event *)event forCheckins:(NSArray *)checkins;

+ (void)logInWithCompletion:(void (^)(User *user, NSError *error))block;
+ (User *)currentUser;
@end
