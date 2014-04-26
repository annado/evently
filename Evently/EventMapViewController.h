//
//  EventMapViewController.h
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ComposerViewController.h"

@interface EventMapViewController : UIViewController <MKMapViewDelegate,
    ComposerViewDelegate>
- (id)initWithEvent:(Event *)event;
@end
