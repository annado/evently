//
//  MapAnnotationView.h
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SMCalloutView.h"

@protocol ImageAnnotation <NSObject>

- (NSURL *)urlForImage;

@optional

- (NSString *)textForCallout;

@end


@interface ImageWithCalloutAnnotationView : MKAnnotationView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *pinView;
@property (nonatomic, weak) MKMapView *mapView;

- (void)setPinTintColor:(UIColor *)pinTintColor;
- (void)updateCallout;

@end
