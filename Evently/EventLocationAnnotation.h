//
//  EventLocationAnnotation.h
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class EventAttendeeAnnotationView;

@interface EventLocationAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithEvent:(Event *)event;
- (MKPinAnnotationView *)annotationView;
@end
