//
//  SignInViewController.m
//  Evently
//
//  Created by Anna Do on 4/1/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "SignInViewController.h"
#import "User.h"

@interface SignInViewController ()
- (IBAction)onSignInButton:(id)sender;

@end

@implementation SignInViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignInButton:(id)sender
{
    [User logInWithFacebook];
}
@end
