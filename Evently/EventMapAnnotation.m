//
//  MapAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventMapAnnotation.h"

@interface EventMapAnnotation ()
@property (nonatomic, strong) EventCheckin *checkin;
@end

@implementation EventMapAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

@end
