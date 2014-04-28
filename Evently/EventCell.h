//
//  EventCell.h
//  Evently
//
//  Created by Liron Yahdav on 4/8/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>
#import "Event.h"

@interface EventCell : SWTableViewCell

@property (nonatomic, strong) Event *event;

@end
