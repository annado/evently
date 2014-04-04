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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    [_activityIndicator startAnimating];
    [User logInWithCompletion:^(User *user, NSError *error) {
        [_activityIndicator stopAnimating];
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            }
        } else if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:[NSString stringWithFormat:@"Uh oh. An error occurred: %@", error]
                                           delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            });
        }
    }];
}
@end
