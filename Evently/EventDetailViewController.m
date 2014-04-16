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
#import "EventCheckin.h"
#import "EventDetailHeader.h"
#import "EventDetailCell.h"
#import "EventRSVPCell.h"
#import "EventCheckin.h"
#import "UserCheckedInCell.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *checkins;
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
        [EventCheckin checkinsForEvent:_event withCompletion:^(NSArray *checkins, NSError *error) {
            self.checkins = checkins;
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
        [[User currentUser] getCheckinForEvent:_event completion:^(EventCheckin *checkin, NSError *error) {
            [self setCheckedIn];
        }];
    }
}

- (void)onCheckinButton:(UIBarButtonItem *)barButtonItem
{
    [_event checkinCurrentUser];
    [self setCheckedIn];
}

- (void)setCheckedIn
{
    self.navigationItem.rightBarButtonItem.title = @"Checked in";
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return self.checkins.count;
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
        } else {
            EventRSVPCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RSVPCellIdentifier forIndexPath:indexPath];
            cell.event = _event;
            return cell;
        }
    } else {
        UserCheckedInCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CheckinCellIdentifier forIndexPath:indexPath];
        cell.checkin = self.checkins[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == 0) ? [EventDetailCell heightForEvent:_event] : [EventRSVPCell heightForEvent:_event];
}

#pragma mark - EventRSVPCell protocol
- (void)onLocation:(Event *)event
{
    NSLog(@"Open location action sheet");
}

@end
