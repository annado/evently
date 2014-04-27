//
//  EventLocationAnnotation.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "EventLocationAnnotation.h"
#import "ImageWithCalloutAnnotationView.h"

@interface EventLocationAnnotation ()
@property (nonatomic, strong) Event *event;
@property (nonatomic, copy) NSString *title;
@end

@implementation EventLocationAnnotation

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        _coordinate = _event.location.latLon.coordinate;
        _title = _event.location.name;
    }
    return self;
}

- (NSURL *)urlForImage {
    return [self.event coverPhotoURL];
}

@end
