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

    dictionary = dictionary[@"venue"];
    
    location.name = dictionary[@"name"];
    location.streetAddress = dictionary[@"street"];
    location.city = dictionary[@"city"];
    location.country = dictionary[@"country"];
    location.state = dictionary[@"state"];
    location.zipCode = dictionary[@"zip"];

    if (dictionary[@"latitude"] && dictionary[@"longitude"]) {
        location.latLon = [[CLLocation alloc] initWithLatitude:[dictionary[@"latitude"] floatValue] longitude:[dictionary[@"longitude"] floatValue]];
    }
    
    return location;
}

- (NSString *)displayLocation
{
    NSString *location;
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (_name.length > 0) {
        return _name;
    }
    
    if (_streetAddress.length > 0) {
        [locations addObject:_streetAddress];
    }
    if (_city.length > 0) {
        [locations addObject:_city];
    }

    location = [locations componentsJoinedByString:@", "];
    
    if (_city.length == 0 && _zipCode.length > 0) {
        location = [location stringByAppendingFormat:@" %@", _zipCode];
    }
    
    return location;
}

@end
