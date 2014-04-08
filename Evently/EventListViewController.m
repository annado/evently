//
//  EventListViewController.m
//  Evently
//
//  Created by Liron Yahdav on 4/7/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventListViewController.h"
#import "Event.h"
#import "EventCell.h"

@interface EventListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *events;

@end

@implementation EventListViewController

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

    UINib *eventCell = [UINib nibWithNibName:@"EventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"EventCell"];

    [Event eventsForUser:[User currentUser] withStatus:AttendanceAll withIncludeAttendees:NO withCompletion:^(NSArray *events, NSError *error) {
        self.events = events;
        [self.tableView reloadData];
    }];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    Event *event = self.events[indexPath.row];
    cell.event = event;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0; // TODO: don't hardcode
}

@end
