//
//  RealtimeLocationManager.m
//  Evently
//
//  Created by Liron Yahdav on 4/26/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "RealtimeLocationManager.h"

@implementation RealtimeLocationManager

+ (RealtimeLocationManager *)sharedInstance {
    static RealtimeLocationManager *instance = nil;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        instance = [[RealtimeLocationManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)startUpdatingLocationWithDelegate:(id<CLLocationManagerDelegate>)delegate {
    self.locationManager.delegate = delegate;
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

@end
