//
//  Location.m
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "Location.h"

@implementation Location

+ (Location *)locationWithDictionary:(NSDictionary *)dictionary {
    Location *location = [[Location alloc] init];

    location.streetAddress = dictionary[@"street"];
    location.city = dictionary[@"city"];
    location.country = dictionary[@"country"];
    location.state = dictionary[@"state"];
    location.zipCode = dictionary[@"zip"];

    location.latitude = [dictionary[@"latitude"] floatValue];
    location.longitude = [dictionary[@"longitude"] floatValue];
    
    return location;
}

@end
