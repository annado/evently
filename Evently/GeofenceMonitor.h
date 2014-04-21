// Adapted from http://hayageek.com/ios-geofencing-api/
//
//  GeofenceMonitor.h
//  Geofening
//
//  Created by KH1386 on 10/8/13.
//  Copyright (c) 2013 KH1386. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GeofenceMonitor;

@protocol GeofenceMonitorDelegate <NSObject>

- (void)geofenceMonitor:(GeofenceMonitor *)geofenceMonitor didEnterRegion:(CLRegion *)region;

@end

@interface GeofenceMonitor : NSObject<CLLocationManagerDelegate>
+(GeofenceMonitor *) sharedInstance;

-(void) addGeofence:(NSDictionary*) dict;
-(void) removeGeofence:(NSDictionary*) dict;
-(void) clearGeofences;
-(void) findCurrentFence;
-(BOOL)checkLocationManager;
@property CLLocationManager * locationManager;
@property (nonatomic, weak) id<GeofenceMonitorDelegate> delegate;

@end
