//
//  EventAttendeeAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/22/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "EventAttendeeAnnotation.h"
#import "EventAttendeeAnnotationView.h"
#import "UserEventLocation.h"

@interface EventAttendeeAnnotation ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@implementation EventAttendeeAnnotation

- (id)initWithUserEventLocation:(UserEventLocation *)userEventLocation {
    self = [super init];
    if (self) {
        self.user = userEventLocation.user;
        self.coordinate = [userEventLocation coordinate];
    }
    return self;
}

- (id)initWithUser:(User *)user coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.user = user;
        self.coordinate = coordinate;
    }
    return self;
}

- (EventAttendeeAnnotationView *)annotationView
{
    EventAttendeeAnnotationView *annotationView = [[EventAttendeeAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"EventAttendeeAnnotationView"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    [annotationView.imageView setImageWithURL:[_user avatarURL]];
    return annotationView;
}

@end
