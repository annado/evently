//
//  StatusMessage.h
//  Evently
//
//  Created by Ning Liang on 4/26/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSMessage.h"

@interface StatusMessage : JSMessage

@property (nonatomic, strong) NSString *userFacebookID;
@property (nonatomic, strong) NSString *userFullName;

- (NSString *)serializeMessage;
+ (StatusMessage *)deserializeMessage:(NSString *)serialized;

+ (StatusMessage *)statusMessageWithText:(NSString *)text userFacebookID:(NSString *)userFacebookID userFullName:(NSString *)userFullName date:(NSDate *)date;

+ (void)updateStatusForUser:(User *)user event:(Event *)event statusMessage:(StatusMessage *)statusMessage;
+ (void)getStatusesForEvent:(Event *)event withCompletion:(void (^)(NSArray *statusMessages, NSError *error))block;
+ (void)latestStatusForEvent:(Event *)event withCompletion:(void (^)(StatusMessage *statusMessage, NSError *error))block;;

@end
