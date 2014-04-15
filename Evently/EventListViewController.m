//
//  EventListViewController.m
//  Evently
//
//  Created by Liron Yahdav on 4/7/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventListViewController.h"
#import "EventDetailViewController.h"
#import "EventCell.h"
#import "EventNowCell.h"
#import "AppDelegate.h"

const NSInteger kHappeningNowSection = 0;
const NSInteger kUpcomingSection = 1;

@interface EventListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation EventListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Events";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadEvents) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UINib *eventCell = [UINib nibWithNibName:@"EventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"EventCell"];
    
    UINib *eventNowCell = [UINib nibWithNibName:@"EventNowCell" bundle:nil];
    [self.tableView registerNib:eventNowCell forCellReuseIdentifier:@"EventNowCell"];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButtonTap)];
    
    [self loadEvents];
}

- (void)loadEvents {
    // TODO: move outside this VC?
    [Event eventsForUser:[User currentUser] withStatus:EventAttendanceAll withIncludeAttendees:NO withCompletion:^(NSArray *events, NSError *error) {
        // TODO: ugly code, refactor
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]];
        [AppDelegate sharedInstance].nowEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == YES)"]] sortedArrayUsingDescriptors:sortDescriptors];
        [AppDelegate sharedInstance].upcomingEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == NO && startTime >= %@)", [NSDate date]]] sortedArrayUsingDescriptors:sortDescriptors];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)onLogoutButtonTap {
    [User logOut];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kHappeningNowSection:
            return [AppDelegate sharedInstance].nowEvents.count;
        case kUpcomingSection:
            return [AppDelegate sharedInstance].upcomingEvents.count;
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kHappeningNowSection:
            return @"Happening Now";
        case kUpcomingSection:
            return @"Upcoming";
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kHappeningNowSection) {
        EventNowCell *eventNowCell = [self.tableView dequeueReusableCellWithIdentifier:@"EventNowCell" forIndexPath:indexPath];
        Event *event = [AppDelegate sharedInstance].nowEvents[indexPath.row];
        eventNowCell.event = event;
        return eventNowCell;
    } else if (indexPath.section == kUpcomingSection) {
        EventCell *eventCell = [self.tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        Event *event = [AppDelegate sharedInstance].upcomingEvents[indexPath.row];
        eventCell.event = event;
        return eventCell;
    } else {
        NSLog(@"Invalid table view section %@", indexPath);
        return nil;
    }
}

#pragma mark - UITableViewDelegate

// TODO flexible layout height using a prototype cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kHappeningNowSection) {
        return 160;
    } else {
        return 66.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [AppDelegate sharedInstance].upcomingEvents[indexPath.row];
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}

@end
