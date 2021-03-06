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
#import "UserEventLocation.h"

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
