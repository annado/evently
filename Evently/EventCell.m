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
@property (weak, nonatomic) IBOutlet UILabel *attendanceLabel;

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
    _event = event;
    self.eventNameLabel.text = event.name;
    self.eventTimeLabel.text = [self.event displayDate];
    self.attendanceLabel.text = [NSString stringWithFormat:@"Attendance status: %@", self.event.displayUserAttendanceStatus];
    [self.eventImage setImageWithURL:event.coverPhotoURL];
}

@end
