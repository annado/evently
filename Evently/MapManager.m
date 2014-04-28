//
//  AttendeeAnnotationManager.m
//  Evently
//
//  Created by Ning Liang on 4/27/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "MapManager.h"
#import "EventAttendeeAnnotation.h"
#import "Event.h"
#import "EventLocationAnnotation.h"
#import "UIImageView+AFNetworking.h"

@interface MapManager ()

@property (nonatomic, strong) NSMutableDictionary *attendeeAnnotations;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) Event *event;

@end

@implementation MapManager

- (id)initWithMapView:(MKMapView *)mapView event:(Event *)event {
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.event = event;
        self.attendeeAnnotations = [[NSMutableDictionary alloc] init];
        
        self.mapView.delegate = self;
        
        // Initial pin
        [self addPinForEventLocation];
    }
    return self;
}

// Creates the annotation if it doesn't exist
- (void)updateUserLocation:(NSString *)userFacebookID latitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    if (self.attendeeAnnotations[userFacebookID]) {
        EventAttendeeAnnotation *annotation = self.attendeeAnnotations[userFacebookID];
        [self animateCoordinateChange:annotation location:coordinate];
    } else {
        [User findUserWithFacebookID:userFacebookID completion:^(User *user, NSError *error) {
            [self addAnnotationForUser:user latitude:latitude longitude:longitude];
            [self zoomToFitAnnotations:YES];
        }];
    }
}

// Sets the status on the annotation if it exists
- (void)updateUserStatus:(NSString *)userFacebookID text:(NSString *)text {
    EventAttendeeAnnotation *annotation = self.attendeeAnnotations[userFacebookID];
    if (annotation) {
        annotation.status = text;
        ImageWithCalloutAnnotationView *annotationView = (ImageWithCalloutAnnotationView*)[self.mapView viewForAnnotation:annotation];
        [annotationView updateCallout];
        [self zoomToFitAnnotations:YES];
    }
}

- (void)bootstrapFromUserEventLocations:(NSArray *)userEventLocations {
    for (UserEventLocation *userEventLocation in userEventLocations) {
        [self addAnnotationForUser:userEventLocation.user latitude:userEventLocation.latitude longitude:userEventLocation.longitude];
    }
    [self zoomToFitAnnotations:NO];
}

- (void)addAnnotationForUser:(User *)user latitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    if (!self.attendeeAnnotations[user.facebookID]) {
        EventAttendeeAnnotation *annotation = [[EventAttendeeAnnotation alloc] initWithUser:user coordinate:coordinate];
        [self.mapView addAnnotation:annotation];
        [self.attendeeAnnotations setObject:annotation forKey:user.facebookID];
    }
}

- (void)zoomToFitAnnotations:(BOOL)animated {
    [self.mapView showAnnotations:self.mapView.annotations animated:animated];
}

- (void)addPinForEventLocation
{
    if (_event.location.latLon) {
        EventLocationAnnotation *annotation = [[EventLocationAnnotation alloc] initWithEvent:_event];
        [self.mapView addAnnotation:annotation];
        
        // make the default region size smaller
        // this is only a problem if there is only 1 pin
        self.mapView.region = MKCoordinateRegionMake(_event.location.latLon.coordinate, MKCoordinateSpanMake(0.005, 0.005));
    }
}

- (void)animateCoordinateChange:(id <MKAnnotation>)annotation location:(CLLocationCoordinate2D)coordinate
{
    [UIView animateWithDuration:1.0 animations:^{
        annotation.coordinate = coordinate;
    }];
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[EventLocationAnnotation class]] || [annotation isKindOfClass:[EventAttendeeAnnotation class]]) {
        ImageWithCalloutAnnotationView *annotationView = (ImageWithCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ImageWithCalloutAnnotationView"];
        
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[ImageWithCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ImageWithCalloutAnnotationView"];
            annotationView.enabled = YES;
            annotationView.canShowCallout = NO;
            annotationView.mapView = mapView;
        }
        [annotationView updateCallout];
        NSAssert([annotation conformsToProtocol:@protocol(ImageAnnotation)], @"Don't know how to get image for a %@ annotation", [annotation class]);
        id<ImageAnnotation> imageAnnotation = (id<ImageAnnotation>)annotation;
        [annotationView.imageView setImageWithURL:[imageAnnotation urlForImage]];
        
        return annotationView;
    }
    
    return nil;
}

@end
