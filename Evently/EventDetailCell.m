//
//  EventRSVPCell.m
//  Evently
//
//  Created by Anna Do on 4/13/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventDetailCell.h"
#import "CheckinButton.h"

@interface EventDetailCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet CheckinButton *checkinButton;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@end

@implementation EventDetailCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event
{
    _event = event;
    NSString *location = [_event.location displayLocation];
    self.locationLabel.text = location;
    if (location.length == 0) {
        self.locationIcon.hidden = YES;
    }
    
    self.dateLabel.text = [_event displayDate];
    
    [self addSubview:self.checkinButton];
    self.checkinButton.event = _event;
}

+ (CGFloat)heightForEvent:(Event *)event
{
    CGFloat height = 20 + 20 + 17;
    height += 55; // checkin button
    NSString *location = [event.location displayLocation];
    if (location.length > 0) {
        height += 27;
    }
    return height;
}

@end
