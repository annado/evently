//
//  Location.h
//  Evently
//
//  Created by Ning Liang on 4/6/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *streetAddress;
@property (nonatomic, strong) NSString *zipCode;

@property (nonatomic, strong) CLLocation *latLon;

+ (Location *)locationWithDictionary:(NSDictionary *)dictionary;
- (NSString *)displayLocation;
@end
