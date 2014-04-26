//
//  RealtimeLocationManager.h
//  Evently
//
//  Created by Liron Yahdav on 4/26/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RealtimeLocationManager : NSObject

+ (RealtimeLocationManager *)sharedInstance;

- (void)startUpdatingLocationWithDelegate:(id<CLLocationManagerDelegate>)delegate;
- (void)stopUpdatingLocation;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
