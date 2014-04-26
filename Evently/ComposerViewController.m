//
//  ComposerViewController.m
//  Evently
//
//  Created by Anna Do on 4/25/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "ComposerViewController.h"

@interface ComposerViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation ComposerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;

    }
    return self;
}

- (void)onCancel:(UIBarButtonItem *)buttonItem
{
    [self.delegate composeViewController:self posted:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.delegate = self;
    [self.textView becomeFirstResponder];
    [self zoomToUserLocation];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)zoomToUserLocation
{
    if (self.mapView.userLocation) {
        self.mapView.region = MKCoordinateRegionMake(self.mapView.userLocation.location.coordinate, MKCoordinateSpanMake(0.005, 0.005));
    }
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomToUserLocation];
}

@end
