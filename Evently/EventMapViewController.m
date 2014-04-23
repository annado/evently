//
//  EventMapViewController.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventMapViewController.h"
#import "EventAttendeeAnnotation.h"
#import "EventLocationAnnotation.h"
#import "EventAttendeeAnnotationView.h"

#import "EventDetailViewController.h"
#import "EventCheckin.h"

@interface EventMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Event *event;
@end

@implementation EventMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(onDetailsButton)];

    }
    return self;
}

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    [EventCheckin checkinsForEvent:_event withCompletion:^(NSArray *checkins, NSError *error) {
        for (int i = 0; i < checkins.count; i++) {
            [self addPinForEventCheckin:checkins[i]];
        }
    }];

    [self addEventLocationPin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDetailsButton
{
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc] initWithEvent:_event];
    [self.navigationController pushViewController:eventDetailViewController animated:YES];

}

- (void)addEventLocationPin
{
    if (_event.location.latLon) {
        // location pin
        CLLocationCoordinate2D coordinate = _event.location.latLon.coordinate;
        EventLocationAnnotation *annotation = [[EventLocationAnnotation alloc] initWithTitle:_event.location.name location:coordinate];
        [self.mapView addAnnotation:annotation];
        [self.mapView selectAnnotation:annotation animated:YES];
    }
}

- (void)addPinForEventCheckin:(EventCheckin *)checkin
{
    CLLocationCoordinate2D coordinate = _event.location.latLon.coordinate; // TODO
    
    coordinate.latitude += 10;
    coordinate.latitude += 10;

    EventAttendeeAnnotation *annotation = [[EventAttendeeAnnotation alloc] initWithEventCheckin:checkin location:coordinate];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    [self zoomMapToFitAnnotations];
}

- (void)zoomMapToFitAnnotations
{
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomMapToFitAnnotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[EventLocationAnnotation class]]) {
        EventLocationAnnotation *location = (EventLocationAnnotation *)annotation;
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"EventLocationAnnotationView"];
        
        if (annotationView) {
            annotationView.annotation = location;
        } else {
            annotationView = [location annotationView];
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[EventAttendeeAnnotation class]]) {
        EventAttendeeAnnotation *location = (EventAttendeeAnnotation *)annotation;
        EventAttendeeAnnotationView *annotationView = (EventAttendeeAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"EventAttendeeAnnotationView"];
        
        if (annotationView) {
            annotationView.annotation = location;
        } else {
            annotationView = [location annotationView];
        }
        
        return annotationView;
    }

    
    return nil;
}

@end
