//
//  EventAttendeeAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/22/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "EventAttendeeAnnotation.h"
#import "ImageWithCalloutAnnotationView.h"
#import "UserEventLocation.h"
#import "SMCalloutView.h"

@interface EventAttendeeAnnotation ()
@end

@implementation EventAttendeeAnnotation

- (id)initWithUserEventLocation:(UserEventLocation *)userEventLocation {
    self = [super init];
    if (self) {
        _user = userEventLocation.user;
        _coordinate = [userEventLocation coordinate];
    }
    return self;
}

- (id)initWithUser:(User *)user coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _user = user;
        _coordinate = coordinate;
    }
    return self;
}

- (NSURL *)urlForImage {
    return [self.user avatarURL];
}

- (NSString *)textForCallout {
    return self.status;
}

@end
