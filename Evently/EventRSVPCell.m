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
- (IBAction)onRSVP:(id)sender;
@end

@implementation EventRSVPCell

- (void)awakeFromNib
{
    // Initialization code
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
}

@end
