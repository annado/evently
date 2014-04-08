//
//  EventCell.m
//  Evently
//
//  Created by Liron Yahdav on 4/8/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventCell.h"

@interface EventCell ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;

@end

@implementation EventCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event {
    self.eventNameLabel.text = event.name;
    self.eventTimeLabel.text = [event.startTime description];
}

@end
