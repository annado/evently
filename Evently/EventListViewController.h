//
//  EventListViewController.h
//  Evently
//
//  Created by Liron Yahdav on 4/7/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@interface EventListViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate,
    SWTableViewCellDelegate>

@end
