//
//  EventDetailViewController.m
//  Evently
//
//  Created by Anna Do on 4/12/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MapKit/MapKit.h>
#import "UserEventLocation.h"
#import "EventDetailHeader.h"
#import "EventDetailCell.h"
#import "EventRSVPCell.h"
#import "UserCheckedInCell.h"
#import "UserGridCell.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *userEventLocations;
@end

@implementation EventDetailViewController

const NSInteger kCheckinsSection = 2;

static NSString *RSVPCellIdentifier = @"EventRSVPCell";
static NSString *DetailCellIdentifier = @"EventDetailCell";
static NSString *CheckinCellIdentifier = @"UserCheckedInCell";

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        self.title = event.name;
        [self addCheckinButton];
        [UserEventLocation userEventLocationsForEvent:_event withCompletion:^(NSArray *userEventLocations, NSError *error) {
            self.userEventLocations = userEventLocations;
            [self.tableView reloadData];
        }];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // Register cells
    [self.tableView registerNib:[UINib nibWithNibName:@"EventRSVPCell" bundle:nil] forCellReuseIdentifier:RSVPCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailCell" bundle:nil] forCellReuseIdentifier:DetailCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCheckedInCell" bundle:nil] forCellReuseIdentifier:CheckinCellIdentifier];

    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"EventDetailHeader"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserGridCell" bundle:nil] forCellReuseIdentifier:@"UserGridCell"];

    EventDetailHeader *eventDetailHeader = [[EventDetailHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    eventDetailHeader.event = _event;
    self.tableView.tableHeaderView = eventDetailHeader;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCheckinButton
{
    if (_event.isHappeningNow) {
        UIBarButtonItem *checkinButton = [[UIBarButtonItem alloc] initWithTitle:@"Check in" style:UIBarButtonItemStylePlain target:self action:@selector(onCheckinButton:)];
        self.navigationItem.rightBarButtonItem = checkinButton;
        
        [UserEventLocation user:[User currentUser] isAtEvent:_event withCompletion:^(BOOL isPresent, NSError *error) {
            self.checkedIn = isPresent;
        }];
    }
}

- (void)onCheckinButton:(UIBarButtonItem *)barButtonItem
{
    [_event checkinUser:[User currentUser]];
    [self setCheckedIn:YES];
}

- (void)setCheckedIn:(BOOL)checkedin
{
    _checkedIn = checkedin;
    if (checkedin) {
        self.navigationItem.rightBarButtonItem.title = @"Checked in";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Check in";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return self.userEventLocations.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            EventDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
            cell.event = _event;
            return cell;
        } else if (indexPath.row == 1) {
            EventRSVPCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RSVPCellIdentifier forIndexPath:indexPath];
            cell.event = _event;
            return cell;
        } else {
            UserGridCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserGridCell" forIndexPath:indexPath];
            cell.gridTitle = @"Attending";
            cell.userFacebookIds = _event.attendingUsers;
            return cell;
        }
    } else {
        UserCheckedInCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CheckinCellIdentifier forIndexPath:indexPath];
        cell.userEventLocation = self.userEventLocations[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [EventDetailCell heightForEvent:_event];
    } else if (indexPath.row == 1) {
        return [EventRSVPCell heightForEvent:_event];
    } else {
        // TODO get height based on number of facebook attendees
        return 180;
    }
}

#pragma mark - EventRSVPCell protocol
- (void)onLocation:(Event *)event
{
    NSLog(@"Open location action sheet");
}

@end
