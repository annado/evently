//
//  AppDelegate.m
//  Evently
//
//  Created by Anna Do on 4/1/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "AppDelegate.h"
#import "DateHelper.h"
#import "SignInViewController.h"
#import "ProfileViewController.h"
#import "User.h"
#import "EventCheckin.h"
#import "EventListViewController.h"
#import "CRToast.h"
#import "EventNotification.h"
#import "GeofenceMonitor.h"

@interface AppDelegate () <GeofenceMonitorDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initParse];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        NSString *eventFacebookID = [EventNotification getEventIDForNotification:localNotification];

        // TODO: open app to this Event [anna]
        NSLog(@"LocalNotification: %@", eventFacebookID);
    }
    
    [GeofenceMonitor sharedInstance].delegate = self;
    [self setDefaultAppearance];
    [self setInitialRootViewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)initParse
{
    // Parse subclasses
    [User registerSubclass];
    [EventCheckin registerSubclass];
    
    [Parse setApplicationId:@"2DhYRY420kuYwMv12BZrEzpbjebGS9wVlCtJKdnz"
                  clientKey:@"9zookCNyg4AOaVed5UnrSdCVx6wwEgNeEgmj9s2j"];
    [PFFacebookUtils initializeFacebook];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setInitialRootViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootViewController) name:UserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootViewController) name:UserDidLogoutNotification object:nil];
    [self updateRootViewController];
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
    self.window.backgroundColor = [UIColor whiteColor];

    [[UIView appearance] setTintColor:[UIColor orangeColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                          NSForegroundColorAttributeName: [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0],
                                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17.0],
                                                          }];
}

+ (AppDelegate *)sharedInstance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)loadEventsWithCompletion:(void (^)(NSArray *events, NSError *error))completionBlock {
    [[GeofenceMonitor sharedInstance] clearGeofences];
    [Event eventsForUser:[User currentUser] withStatus:EventAttendanceAll withIncludeAttendees:NO withCompletion:^(NSArray *events, NSError *error) {
        // TODO: ugly code, refactor
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]];
        self.nowEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == YES)"]] sortedArrayUsingDescriptors:sortDescriptors];
        self.upcomingEvents = [[events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(isHappeningNow == NO && startTime >= %@)", [NSDate date]]] sortedArrayUsingDescriptors:sortDescriptors];
        [Event addGeofencesForEvents:self.nowEvents];
        if (completionBlock) {
            completionBlock(events, error);
        }
    }];
}

#pragma mark - GeofenceMonitorDelegate

- (void)geofenceMonitor:(GeofenceMonitor *)geofenceMonitor didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region - %@", region.identifier);
    [Event eventForFacebookID:region.identifier withIncludeAttendees:NO withCompletion:^(Event *event, NSError *error) {
        [event checkinCurrentUser];
        [self fireLocalNotificationWithMessage:[NSString stringWithFormat:@"You've been checked in to %@", event.name]];
    }];
}

#pragma mark - Push Notifications
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive) {
        [EventNotification handleForegroundLocalNotification:notification];
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
