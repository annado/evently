//
//  EventNowCell.m
//  Evently
//
//  Created by Ning Liang on 4/15/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventNowCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface EventNowCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation EventNowCell

- (void)awakeFromNib
{
    // Initialization code
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"h:mm a";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.titleLabel.text = event.name;
    self.timeLabel.text = [self.timeFormatter stringFromDate:event.startTime];
    self.locationLabel.text = event.location.streetAddress;
    [self.backgroundImageView setImageWithURL:event.coverPhotoURL];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        
    self.layer.masksToBounds = YES;
}

@end
