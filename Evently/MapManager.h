//
//  AttendeeAnnotationManager.h
//  Evently
//
//  Created by Ning Liang on 4/27/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapManager : NSObject <MKMapViewDelegate>

- (id)initWithMapView:(MKMapView *)mapView event:(Event *)event;
- (void)updateUserLocation:(NSString *)userFacebookID latitude:(CGFloat)latitude longitude:(CGFloat)longitude;
- (void)updateUserStatus:(NSString *)userFacebookID text:(NSString *)text;

// Bulk set with pre-loaded users, for initialization
- (void)bootstrapFromUserEventLocations:(NSArray *)userEventLocations;

@end
