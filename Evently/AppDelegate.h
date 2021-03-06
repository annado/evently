//
//  AppDelegate.h
//  Evently
//
//  Created by Anna Do on 4/1/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSArray *updateLocationEvents;
@property (nonatomic, strong) NSArray *nowEvents;
@property (nonatomic, strong) NSArray *upcomingEvents;

+ (AppDelegate *)sharedInstance;
- (void)loadEventsWithCompletion:(void (^)(NSArray *events, NSError *error))completionBlock;

@end
