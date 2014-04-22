//
//  MapAnnotation.h
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class EventMapAnnotationView;

@interface EventMapAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithTitle:(NSString *)title location:(CLLocationCoordinate2D)coordinate;
- (EventMapAnnotationView *)annotationView;
@end
