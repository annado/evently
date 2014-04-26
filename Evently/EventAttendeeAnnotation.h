//
//  EventAttendeeAnnotation.h
//  Evently
//
//  Created by Anna Do on 4/22/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UserEventLocation.h"

@class EventAttendeeAnnotationView;

@interface EventAttendeeAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *status;

- (id)initWithUserEventLocation:(UserEventLocation *)userEventLocation;
- (id)initWithUser:(User *)user coordinate:(CLLocationCoordinate2D)coordinate;

- (EventAttendeeAnnotationView *)annotationView;

@end
