//
//  EventDetailViewController.m
//  Evently
//
//  Created by Anna Do on 4/12/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "EventDetailViewController.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rsvpSegmentedControl;

@end

@implementation EventDetailViewController

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        self.title = event.name;
        [self initRSVPControl];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initRSVPControl
{
    [self.rsvpSegmentedControl addTarget:self
                                  action:@selector(onRSVP:)
                        forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateRSVP];

    self.titleLabel.text = _event.name;
    if (_event.coverPhotoURL) {
        [self.coverImageView setImageWithURL:_event.coverPhotoURL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRSVP:(UISegmentedControl *)control
{
    // TODO:
    NSLog(@"onRSVP: %d", control.selectedSegmentIndex);
}

- (void)updateRSVP
{
    NSInteger index;
    
    switch (_event.userAttendanceStatus) {
        case EventAttendanceYes:
            index = 0;
            break;
        case EventAttendanceMaybe:
            index = 1;
            break;
        case EventAttendanceNo:
            index = 2;
            break;
        case EventAttendanceNotReplied:
            index = -1;
            break;
        default:
            index = -1;
            break;
    }
    self.rsvpSegmentedControl.selectedSegmentIndex = index;
}

@end
