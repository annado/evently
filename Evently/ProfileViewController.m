//
//  ProfileViewController.m
//  Evently
//
//  Created by Anna Do on 4/2/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ProfileViewController.h"
#import "User.h"
#import "Event.h"
#import "EventCheckin.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)onLogOutButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ProfileViewController

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
    User *user = [User currentUser];
    self.nameLabel.text = user[@"name"];
    [self.imageView setImageWithURL:[user avatarURL]];
    
    [Event eventsForUser:user withStatus:AttendanceAll withIncludeAttendees:NO withCompletion:^(NSArray *events, NSError *error) {
        Event *event = events[6];
        [EventCheckin user:[User currentUser] didArriveAtEvent:event withCompletion:^(NSError *error) {
            NSLog(@"User did checkin to event: %@", user[@"facebookID"]);
            
            [EventCheckin currentEventForUser:user withIncludeAttendees:NO withCompletion:^(Event *innerEvent, NSError *error) {
                NSLog(@"Current event for user: %@", innerEvent.facebookID);
                
                [EventCheckin usersAtEvent:event withCompletion:^(NSArray *users, NSError *error) {
                    NSLog(@"%d users at event", [users count]);
                    
                    [EventCheckin user:user didDepartEvent:event withCompletion:^(NSError *error) {
                        NSLog(@"User did checkout of event");
                        
                        [EventCheckin currentEventForUser:user withIncludeAttendees:NO withCompletion:^(Event *innerEvent2, NSError *error) {
                            NSLog(@"Current event for user: %@", innerEvent2.facebookID);
                            
                            [EventCheckin usersAtEvent:event withCompletion:^(NSArray *users, NSError *error) {
                                NSLog(@"%d users at event", [users count]);
                            }];
                        }];
                    }];
                }];
            }];
            
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogOutButton:(id)sender {
    [User logOut];
}

@end
