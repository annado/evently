//
//  EventDetailViewController.m
//  Evently
//
//  Created by Anna Do on 4/12/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "EventDetailViewController.h"
#import "EventDetailHeader.h"
#import "EventRSVPCell.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EventDetailViewController

static NSString *RSVPCellIdentifier = @"EventRSVPCell";

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self) {
        _event = event;
        self.title = event.name;
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

    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"EventDetailHeader"];

    EventDetailHeader *eventDetailHeader = [[EventDetailHeader alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    
    eventDetailHeader.event = _event;
    self.tableView.tableHeaderView = eventDetailHeader;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventRSVPCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RSVPCellIdentifier forIndexPath:indexPath];
    cell.event = _event;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0; // TODO: don't hardcode
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Event *event = self.events[indexPath.row];
//    EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc] initWithEvent:event];
//    [self.navigationController pushViewController:eventDetailViewController animated:YES];
}

@end
