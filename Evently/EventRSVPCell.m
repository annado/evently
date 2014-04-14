//
//  EventRSVPCell.m
//  Evently
//
//  Created by Anna Do on 4/13/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventRSVPCell.h"

@interface EventRSVPCell ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
- (IBAction)onRSVP:(UISegmentedControl *)sender;
@end

@implementation EventRSVPCell

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
    [self setRSVPDisplay];
    
    self.locationLabel.text = [_event.location displayLocation];
    self.dateLabel.text = [_event displayDate];
}

- (void)setRSVPDisplay
{
    NSInteger index;
    
    switch (_event.userAttendanceStatus) {
        case EventAttendanceYes:
            index = 0;
            break;
        case EventAttendanceMaybe:
            index = 1;
            break;
        case EventAttendanceNo:
            index = 2;
            break;
        case EventAttendanceNotReplied:
            index = -1;
            break;
        default:
            index = -1;
            break;
    }
    self.segmentedControl.selectedSegmentIndex = index;
}

- (IBAction)onRSVP:(UISegmentedControl *)sender {
    NSLog(@"onRSVP: %d", sender.selectedSegmentIndex);
    NSInteger selected = sender.selectedSegmentIndex;
    NSInteger status;
    
    // TODO: refactor into some kind of dictionary
    switch (selected) {
        case 0:
            status = EventAttendanceYes;
            break;
        case 1:
            status = EventAttendanceMaybe;
            break;
        case 2:
            status = EventAttendanceNo;
            break;
        case -1:
            status = EventAttendanceNotReplied;
            break;
        default:
            status = EventAttendanceNotReplied;
            break;
    }
    _event.userAttendanceStatus = status;
}

@end
