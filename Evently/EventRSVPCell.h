//
//  EventRSVPCell.h
//  Evently
//
//  Created by Anna Do on 4/13/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventRSVPCell : UITableViewCell
@property (nonatomic, strong) Event *event;
+ (CGFloat)heightForEvent:(Event *)event;
@end

@protocol EventRSVPProtocol <NSObject>

- (void)onLocation:(Event *)event;

@end