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
#import "EventCheckin.h"

@interface EventAttendeeAnnotation ()
@property (nonatomic, strong) EventCheckin *checkin;
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
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

- (id)initWithEventCheckin:(EventCheckin *)checkin location:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _checkin = checkin;
        _title = _checkin.user.name;
        _user = _checkin.user;
        _subtitle = _checkin.displayTextWithoutName;
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
