//
//  EventMapViewController.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventMapViewController.h"
#import "EventMapAnnotation.h"
#import "EventMapAnnotationView.h"

#import "EventDetailViewController.h"

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
    
    if (_event.location.latLon) {
        CLLocationCoordinate2D coordinate = _event.location.latLon.coordinate;
        EventMapAnnotation *annotation = [[EventMapAnnotation alloc] initWithTitle:_event.location.name location:coordinate];
        [self.mapView addAnnotation:annotation];
        [self.mapView selectAnnotation:annotation animated:YES];
        [self zoomMapToFitAnnotations];
    }
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
    if ([annotation isKindOfClass:[EventMapAnnotation class]])
    {
        EventMapAnnotation *location = (EventMapAnnotation *)annotation;
        EventMapAnnotationView *annotationView = (EventMapAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapAnnotationView"];
        
        if (annotationView) {
            annotationView = [location annotationView];
        } else {
            annotationView.annotation = location;
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
