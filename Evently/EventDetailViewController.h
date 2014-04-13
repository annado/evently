//
//  EventDetailViewController.h
//  Evently
//
//  Created by Anna Do on 4/12/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UIViewController
@property (nonatomic, strong) Event *event;
- (id)initWithEvent:(Event *)event;
@end
