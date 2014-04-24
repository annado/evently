//
//  LocationMessage.h
//  Evently
//
//  Created by Ning Liang on 4/23/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationMessage : NSObject

@property (nonatomic, strong) NSString *userFacebookId;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

- (id)initWithUser:(User *)user latitude:(CGFloat)latitude longitude:(CGFloat)longitude;
- (NSString *)serializeMessage;
+ (LocationMessage *)deserializeMessage:(NSString *)string;

@end
