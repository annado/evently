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

const NSInteger kHappeningNowSection = 0;
const NSInteger kUpcomingSection = 1;

@interface EventListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *nowEvents;
@property (nonatomic, strong) NSArray *upcomingEvents;

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

    UINib *eventCell = [UINib nibWithNibName:@"EventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"EventCell"];

    [Event eventsForUser:[User currentUser] withStatus:EventAttendanceAll withIncludeAttendees:NO withCompletion:^(NSArray *events, NSError *error) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime"
                                                                     ascending:YES]];
        self.nowEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == YES)"]] sortedArrayUsingDescriptors:sortDescriptors];
        self.upcomingEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == NO && startTime >= %@)", [NSDate date]]] sortedArrayUsingDescriptors:sortDescriptors];
        [self.tableView reloadData];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButtonTap)];
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
            return 0;
        case kUpcomingSection:
            return self.upcomingEvents.count;
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
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    Event *event = self.upcomingEvents[indexPath.row];
    cell.event = event;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0; // TODO: don't hardcode
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = self.upcomingEvents[indexPath.row];
    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}

@end
