//
//  ComposerViewController.h
//  Evently
//
//  Created by Anna Do on 4/25/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol ComposerViewDelegate;
@interface ComposerViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, weak) id<ComposerViewDelegate> delegate;
@end

@protocol ComposerViewDelegate <NSObject>
- (void)composeViewController:(ComposerViewController *)composerViewController
                  posted:(NSString *)status;
@end