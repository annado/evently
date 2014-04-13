//
//  EventCell.m
//  Evently
//
//  Created by Liron Yahdav on 4/8/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventCell.h"
#import "UIImageView+AFNetworking.h"

@interface EventCell ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;

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

- (NSString *)stringFromEventTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"EEE MMMM d h:mm a"];
    return [formatter stringFromDate:self.event.startTime];
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.eventNameLabel.text = event.name;
    self.eventTimeLabel.text = [self stringFromEventTime];
    [self.eventImage setImageWithURL:event.coverPhotoURL];
}

@end
