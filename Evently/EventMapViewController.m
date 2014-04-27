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
#import "ImageWithCalloutAnnotationView.h"

#import "UserEventLocation.h"
#import "StatusMessage.h"
#import "EventDetailViewController.h"
#import "DAKeyboardControl.h"
#import "MessagesViewController.h"
#import "PubNub.h"
#import "SMCalloutView.h"
#import "UIImageView+AFNetworking.h"

@interface EventMapViewController ()

@property (strong, nonatomic) PHFComposeBarView *composeBarView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSMutableDictionary *attendeeAnnotations;
@property (nonatomic, strong) NSMutableArray *statusMessages;

@end

@implementation EventMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ChatIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onChatButton)];
        UIBarButtonItem *detailsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"InfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onDetailsButton)];
        
        self.navigationItem.rightBarButtonItems = @[chatButton, detailsButton];
        self.attendeeAnnotations = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillToggle:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillToggle:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        self.title = _event.name;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.view addSubview:self.composeBarView];
    
    [self addPinForEventLocation];

    [UserEventLocation userEventLocationsForEvent:_event withCompletion:^(NSArray *userEventLocations, NSError *error) {
        [self addPinsForUserEventLocations:userEventLocations];
    }];
    
     __weak PHFComposeBarView *weakTextView = _composeBarView;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect textViewFrame = weakTextView.frame;
        textViewFrame.origin.y = keyboardFrameInView.origin.y - textViewFrame.size.height;
        weakTextView.frame = textViewFrame;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.event) {
        // Bootstrap the locations and then subscribe to events
        [UserEventLocation userEventLocationsForEvent:self.event withCompletion:^(NSArray *userEventLocations, NSError *error) {
            // Get the latest user event location
            [self addPinsForUserEventLocations:userEventLocations];
            
            [StatusMessage getStatusesForEvent:self.event withCompletion:^(NSArray *statusMessages, NSError *error) {
                [self bootstrapStatusMessages:statusMessages];
                
                // Observe events
                [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *pnMessage) {
                    NSString *channelName = pnMessage.channel.name;
                    if ([channelName isEqualToString:self.event.statusChannel.name]) {
                        StatusMessage *statusMessage = [StatusMessage deserializeMessage:pnMessage.message];
                        [self processStatusMessage:statusMessage];
                    } else if ([channelName isEqualToString:self.event.locationChannel.name]) {
                        LocationMessage *locationMessage = [LocationMessage deserializeMessage:pnMessage.message];
                        [self processLocationMessage:locationMessage];
                    }
                }];
                
                NSLog(@"EventMapViewController: started observing event %@ near (%f, %F)", self.event.facebookID, self.event.location.latLon.coordinate.latitude, self.event.location.latLon.coordinate.longitude);
            }];
        }];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Stop observing events
    if (self.event) {
        [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
        NSLog(@"EventMapViewController: stopped observing event: %@", self.event.facebookID);
    }

    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = nil;
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

- (void)onChatButton {
    MessagesViewController *messagesViewController = [[MessagesViewController alloc] init];
    messagesViewController.event = self.event;
    [self.navigationController pushViewController:messagesViewController animated:YES];
}

- (void)processLocationMessage:(LocationMessage *)locationMessage {
    NSLog(@"Received location for %@ at (%f, %f)", locationMessage.userFacebookId, locationMessage.latitude, locationMessage.longitude);
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(locationMessage.latitude, locationMessage.longitude);
    [User findUserWithFacebookID:locationMessage.userFacebookId completion:^(User *user, NSError *error) {
        [self addAnnotationForUser:user location:coordinate];
    }];
}

- (void)processStatusMessage:(StatusMessage *)statusMessage {
    EventAttendeeAnnotation *annotation = [self getAnnotationFor:statusMessage.userFacebookID];
    [self setStatusForAnnotation:annotation status:statusMessage.text];
    [self.statusMessages addObject:statusMessage];
}

- (void)addPinsForUserEventLocations:(NSArray *)userEventLocations {
    for (UserEventLocation *userEventLocation in userEventLocations) {
        [self addAnnotationForUser:userEventLocation.user location:[userEventLocation coordinate]];
    }
    if (userEventLocations.count > 0) {
        [self zoomToFitAnnotations:YES];
    }
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
}
     
- (void)addPinsForUserEventLocations
{
    [UserEventLocation userEventLocationsForEvent:_event withCompletion:^(NSArray *userEventLocations, NSError *error) {
        for (UserEventLocation *userEventLocation in userEventLocations) {
            [self addPinForUserEventLocation:userEventLocation];
        }
        if (userEventLocations.count > 0) {
            [self zoomToFitAnnotations:YES];
        }
    }];
}

- (void)addAnnotationForUser:(User *)user location:(CLLocationCoordinate2D)coordinate
{
    if (self.attendeeAnnotations[user.facebookID]) {
        // update coordinates
        EventAttendeeAnnotation *annotation = self.attendeeAnnotations[user.facebookID];
        [self animateCoordinateChange:annotation location:coordinate];
    } else {
        EventAttendeeAnnotation *annotation = [[EventAttendeeAnnotation alloc] initWithUser:user coordinate:coordinate];
        [self.mapView addAnnotation:annotation];
        [self.attendeeAnnotations setObject:annotation forKey:user.facebookID];
        [self zoomToFitAnnotation:annotation animated:YES];
    }
}

- (void)setStatusForAnnotation:(EventAttendeeAnnotation *)annotation status:(NSString *)status
{
    if (annotation) {
        [self zoomToFitAnnotation:annotation animated:YES];
        annotation.status = status;
        ImageWithCalloutAnnotationView *annotationView = (ImageWithCalloutAnnotationView*)[self.mapView viewForAnnotation:annotation];
        [annotationView updateCallout];
    }
}

- (EventAttendeeAnnotation *)getAnnotationFor:(NSString *)userFacebookID
{
    return self.attendeeAnnotations[userFacebookID];
}

- (void)bootstrapStatusMessages:(NSArray *)statusMessages {
    self.statusMessages = [statusMessages mutableCopy];

    // Get the latest status message by user
    NSMutableDictionary *latestMessageByUserId = [[NSMutableDictionary alloc] init];
    for (StatusMessage *statusMessage in self.statusMessages) {
        latestMessageByUserId[statusMessage.userFacebookID] = statusMessage;
    }
    
    // Set the annotation status call outs
    for (NSString *userFacebookId in latestMessageByUserId) {
        StatusMessage *message = latestMessageByUserId[userFacebookId];
        EventAttendeeAnnotation *annotation = [self getAnnotationFor:userFacebookId];
        [self setStatusForAnnotation:annotation status:message.text];
    }
    
}

- (void)animateCoordinateChange:(id <MKAnnotation>)annotation location:(CLLocationCoordinate2D)coordinate
{
    [UIView animateWithDuration:1.0 animations:^{
        annotation.coordinate = coordinate;
    }];
}

- (void)zoomToFitAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated
{
    if (![self isAnnotationVisible:annotation]) {
        [self.mapView showAnnotations:self.mapView.annotations animated:animated];
    }
}

- (void)zoomToFitAnnotations:(BOOL)animated
{
    [self.mapView showAnnotations:self.mapView.annotations animated:animated];
}

- (BOOL)isAnnotationVisible:(id <MKAnnotation>)annotation
{
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleMapRect];
    return [visibleAnnotations containsObject:annotation];
}

#pragma mark - ComposeBar methods
- (PHFComposeBarView *)composeBarView
{
    if (!_composeBarView) {
        CGRect viewBounds = [self.view bounds];
        CGRect frame = CGRectMake(0.0f,
                                  viewBounds.size.height - PHFComposeBarViewInitialHeight,
                                  viewBounds.size.width,
                                  PHFComposeBarViewInitialHeight);
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setPlaceholder:@"Share your status"];
        [_composeBarView setDelegate:self];
        _composeBarView.buttonTintColor = [UIColor orangeColor];
    }
    return _composeBarView;
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView
{
    NSString *status = composeBarView.text;
    [StatusMessage updateStatusForUser:[User currentUser] event:self.event text:status];
    [composeBarView setText:@"" animated:YES];
    [composeBarView resignFirstResponder];
}

- (void)keyboardWillToggle:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    
    CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
    CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;
    
    CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;
    
    CGRect newContainerFrame = [self.view frame];
    newContainerFrame.size.height += sizeChange;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view setFrame:newContainerFrame];
                     }
                     completion:nil];
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
