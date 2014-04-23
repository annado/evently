//
//  EventAttendeeAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/22/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "EventAttendeeAnnotation.h"
#import "EventLocationAnnotationView.h"

@interface EventAttendeeAnnotation ()
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *title;
@end

@implementation EventAttendeeAnnotation

- (id)initWithUser:(User *)user location:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _user = user;
        _title = _user.name;
    }
    return self;
}

- (EventLocationAnnotationView *)annotationView
{
    EventLocationAnnotationView *annotationView = [[EventLocationAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"EventAttendeeAnnotationView"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;

    // TODO: load asynchronously?
    annotationView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[_user avatarURL]]];

    return annotationView;
}

@end
