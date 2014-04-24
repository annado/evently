//
//  LocationMessage.m
//  Evently
//
//  Created by Ning Liang on 4/23/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "LocationMessage.h"

@implementation LocationMessage

- (id)initWithUser:(User *)user latitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    if (self) {
        self.userFacebookId = user.facebookID;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (NSString *)serializeMessage {
    return [NSString stringWithFormat:@"%@,%f,%f", self.userFacebookId, self.latitude, self.longitude];
}

+ (LocationMessage *)deserializeMessage:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@","];

    LocationMessage *message = [[LocationMessage alloc] init];
    message.userFacebookId = [components objectAtIndex:0];
    message.latitude = [[components objectAtIndex:1] floatValue];
    message.longitude = [[components objectAtIndex:2] floatValue];
    
    return message;
}

@end
