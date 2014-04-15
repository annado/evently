//
//  AppDelegate.m
//  Evently
//
//  Created by Anna Do on 4/1/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "AppDelegate.h"
#import "SignInViewController.h"
#import "ProfileViewController.h"
#import "User.h"
#import "EventCheckin.h"
#import "EventListViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager* locManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Parse init
    [User registerSubclass];
    [EventCheckin registerSubclass];
    [Parse setApplicationId:@"2DhYRY420kuYwMv12BZrEzpbjebGS9wVlCtJKdnz"
                  clientKey:@"9zookCNyg4AOaVed5UnrSdCVx6wwEgNeEgmj9s2j"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];

    
    [self setDefaultAppearance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootViewController) name:UserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootViewController) name:UserDidLogoutNotification object:nil];
    [self updateRootViewController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    // TODO only enable if any now events, disable otherwise (and update on a periodic refresh)
    [self.locManager startMonitoringSignificantLocationChanges];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)updateRootViewController
{
    if ([[User currentUser] isLoggedIn]) {
        EventListViewController *eventListViewController = [[EventListViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:eventListViewController];
        self.window.rootViewController = navController;
    } else {
        self.window.rootViewController = [[SignInViewController alloc] init];
    }
}

- (void)setDefaultAppearance
{
//    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]];
    [[UIView appearance] setTintColor:[UIColor orangeColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                          NSForegroundColorAttributeName: [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0],
                                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17.0],
                                                          }];
}

+ (AppDelegate *)sharedInstance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Background Fail %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *mostRecentLocation = locations[locations.count - 1];
    NSLog(@"Background location %.06f %.06f %@", mostRecentLocation.coordinate.latitude, mostRecentLocation.coordinate.longitude, mostRecentLocation.timestamp);
    [self checkinForLocationIfNeeded:mostRecentLocation];
}

- (void)checkinForLocationIfNeeded:(CLLocation *)location {
    for (Event *event in self.nowEvents) {
        if ([event nearLocation:location]) {
            [event checkinCurrentUser];
            [self fireLocalNotificationWithMessage:[NSString stringWithFormat:@"You've been checked in to %@", event.name]];
            return;
        }
    }
}

- (void)fireLocalNotificationWithMessage:(NSString *)message {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = message;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
