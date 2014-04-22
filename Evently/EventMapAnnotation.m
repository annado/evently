//
//  MapAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventMapAnnotation.h"
#import "EventMapAnnotationView.h"

@interface EventMapAnnotation ()
@property (nonatomic, strong) EventCheckin *checkin;
@property (nonatomic, copy) NSString *title;
@end

@implementation EventMapAnnotation

- (id)initWithTitle:(NSString *)title location:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}

- (EventMapAnnotationView *)annotationView
{
    EventMapAnnotationView *annotationView = [[EventMapAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MapAnnotationView"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

@end
