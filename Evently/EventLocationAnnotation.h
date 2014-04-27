//
//  EventLocationAnnotation.h
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ImageWithCalloutAnnotationView.h"

@interface EventLocationAnnotation : NSObject <MKAnnotation, ImageAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithEvent:(Event *)event;
@end
