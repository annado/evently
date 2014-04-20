//
//  EventDetailViewController.h
//  Evently
//
//  Created by Anna Do on 4/12/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventRSVPCell.h"

@interface EventDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EventRSVPProtocol>
@property (nonatomic, strong) Event *event;
@property (nonatomic, assign) BOOL checkedIn;
- (id)initWithEvent:(Event *)event;
@end
