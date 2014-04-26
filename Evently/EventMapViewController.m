//
//  EventMapViewController.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "LocationMessage.h"

#import "EventMapViewController.h"
#import "EventAttendeeAnnotation.h"
#import "EventLocationAnnotation.h"
#import "EventAttendeeAnnotationView.h"
#import "UserEventLocation.h"

#import "EventDetailViewController.h"

@interface EventMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) PNChannel *eventChannel;
@property (nonatomic, strong) NSMutableDictionary *attendeeAnnotations;
@end

@implementation EventMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(onDetailsButton)];
        self.attendeeAnnotations = [[NSMutableDictionary alloc] init];
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
    
    [self addPinForEventLocation];

    [UserEventLocation userEventLocationsForEvent:_event withCompletion:^(NSArray *userEventLocations, NSError *error) {
        for (UserEventLocation *userEventLocation in userEventLocations) {
            [self addPinForUserEventLocation:userEventLocation];
        }
        if (userEventLocations.count > 0) {
            [self zoomToFitAnnotationsWithAnimation:YES];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.event) {
        self.eventChannel = [PNChannel channelWithName:self.event.facebookID shouldObservePresence:NO];
        [PubNub subscribeOnChannel:self.eventChannel];
        
        NSLog(@"Subscribed to channel %@ near (%f, %F)", self.eventChannel.name, self.event.location.latLon.coordinate.latitude, self.event.location.latLon.coordinate.longitude);
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
            if ([message.channel.name isEqualToString:self.eventChannel.name]) {
                LocationMessage *locationMessage = [LocationMessage deserializeMessage:message.message];
                [self processLocationMessage:locationMessage];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.event) {
        [PubNub unsubscribeFromChannel:self.eventChannel];
        [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
        NSLog(@"Unsubscribed from channel %@", self.eventChannel.name);
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

- (void)onShowComposer
{
    ComposerViewController *composerViewController = [[ComposerViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:composerViewController];
    composerViewController.delegate = self;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;

    [self presentViewController:navigationController animated:YES completion: nil];
}

- (void)processLocationMessage:(LocationMessage *)locationMessage {
    NSLog(@"LocationMessage: %@ at (%f, %f)", locationMessage.userFacebookId, locationMessage.latitude, locationMessage.longitude);
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(locationMessage.latitude, locationMessage.longitude);
    [User findUserWithFacebookID:locationMessage.userFacebookId completion:^(User *user, NSError *error) {
        [self addPinForUserLocation:user location:coordinate];
    }];
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

- (void)addPinForUserEventLocation:(UserEventLocation *)userEventLocation {
    EventAttendeeAnnotation *annotation = [[EventAttendeeAnnotation alloc] initWithUserEventLocation:userEventLocation];
    [self.mapView addAnnotation:annotation];
    [self zoomToFitAnnotationsWithAnimation:YES];
}

- (void)addPinForUserLocation:(User *)user location:(CLLocationCoordinate2D)coordinate
{
    if (self.attendeeAnnotations[user.facebookID]) {
        // update coordinates
        EventAttendeeAnnotation *annotation = self.attendeeAnnotations[user.facebookID];
        [self animateCoordinateChange:annotation location:coordinate];
    } else {
        EventAttendeeAnnotation *annotation = [[EventAttendeeAnnotation alloc] initWithUser:user coordinate:coordinate];
        [self.mapView addAnnotation:annotation];
        [self.attendeeAnnotations setObject:annotation forKey:user.facebookID];
        [self zoomToFitAnnotationsWithAnimation:YES];
    }
}

- (void)animateCoordinateChange:(id <MKAnnotation>)annotation location:(CLLocationCoordinate2D)coordinate
{
    [UIView animateWithDuration:1.0 animations:^{
        annotation.coordinate = coordinate;
        [self zoomToFitAnnotationsWithAnimation:YES];
    }];
}

- (void)zoomToFitAnnotationsWithAnimation:(BOOL)animated
{
    [self.mapView showAnnotations:self.mapView.annotations animated:animated];
}

#pragma mark - ComposerViewDelegate methods
- (void)composeViewController:(ComposerViewController *)composerViewController
                       posted:(NSString *)status
{
    if (!status) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomToFitAnnotationsWithAnimation:YES];
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
        EventAttendeeAnnotation *attendeeAnnotation = (EventAttendeeAnnotation *)annotation;
        EventAttendeeAnnotationView *annotationView = (EventAttendeeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"EventAttendeeAnnotationView"];
        
        if (annotationView) {
            annotationView.annotation = attendeeAnnotation;
        } else {
            annotationView = [attendeeAnnotation annotationView];
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
