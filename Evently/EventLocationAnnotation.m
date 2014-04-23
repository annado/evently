//
//  EventLocationAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventLocationAnnotation.h"
#import "EventLocationAnnotationView.h"

@interface EventLocationAnnotation ()
@property (nonatomic, strong) EventCheckin *checkin;
@property (nonatomic, copy) NSString *title;
@end

@implementation EventLocationAnnotation

- (id)initWithTitle:(NSString *)title location:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}

- (EventLocationAnnotationView *)annotationView
{
    EventLocationAnnotationView *annotationView = [[EventLocationAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"EventLocationAnnotationView"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

@end
