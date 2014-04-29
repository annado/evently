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
#import "MapManager.h"

#import "UserEventLocation.h"
#import "StatusMessage.h"
#import "EventDetailViewController.h"
#import "DAKeyboardControl.h"
#import "MessagesViewController.h"
#import "PubNub.h"
#import "SMCalloutView.h"

@interface EventMapViewController ()

@property (strong, nonatomic) PHFComposeBarView *composeBarView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MapManager *mapManager;
@property (nonatomic, strong) Event *event;

@end

@implementation EventMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ChatIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onChatButton)];
        UIBarButtonItem *detailsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"InfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onDetailsButton)];
        
        self.navigationItem.rightBarButtonItems = @[chatButton, detailsButton];
        
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
    
    // Custom initialization
    self.mapManager = [[MapManager alloc] initWithMapView:self.mapView event:self.event];
    [self.view addSubview:self.composeBarView];
    
     __weak PHFComposeBarView *weakTextView = _composeBarView;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect textViewFrame = weakTextView.frame;
        textViewFrame.origin.y = keyboardFrameInView.origin.y - textViewFrame.size.height;
        weakTextView.frame = textViewFrame;
    }];
    
    if (self.event) {
        // Bootstrap the locations and then subscribe to events
        [UserEventLocation userEventLocationsForEvent:self.event withCompletion:^(NSArray *userEventLocations, NSError *error) {
            [self.mapManager bootstrapFromUserEventLocations:userEventLocations];
            
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
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    // Stop observing events
    if (self.event) {
        [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
        NSLog(@"EventMapViewController: stopped observing event: %@", self.event.facebookID);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    [self.mapManager updateUserLocation:locationMessage.userFacebookId latitude:locationMessage.latitude longitude:locationMessage.longitude];
}

- (void)processStatusMessage:(StatusMessage *)statusMessage {
    [self.mapManager updateUserStatus:statusMessage.userFacebookID text:statusMessage.text];
}

- (void)bootstrapStatusMessages:(NSArray *)statusMessages {
    // Get the latest status message by user
    NSMutableDictionary *latestMessageByUserId = [[NSMutableDictionary alloc] init];
    for (StatusMessage *statusMessage in statusMessages) {
        latestMessageByUserId[statusMessage.userFacebookID] = statusMessage;
    }
    
    // Set the annotation status call outs
    for (NSString *userFacebookId in latestMessageByUserId) {
        StatusMessage *message = latestMessageByUserId[userFacebookId];
        [self.mapManager updateUserStatus:userFacebookId text:message.text];
    }
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
    NSLog(@"Keyboard about to toggle");
    
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

@end
