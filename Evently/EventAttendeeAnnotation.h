//
//  EventAttendeeAnnotation.h
//  Evently
//
//  Created by Anna Do on 4/22/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class EventAttendeeAnnotationView;

@interface EventAttendeeAnnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *status;
- (id)initWithEventCheckin:(EventCheckin *)checkin location:(CLLocationCoordinate2D)coordinate;
- (id)initWithUser:(User *)user location:(CLLocationCoordinate2D)coordinate;
- (EventAttendeeAnnotationView *)annotationView;
@end
