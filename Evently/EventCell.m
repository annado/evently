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
@property (weak, nonatomic) IBOutlet UIImageView *attendanceIcon;

@property (nonatomic, strong) UIColor *yesColor;
@property (nonatomic, strong) UIColor *maybeColor;
@property (nonatomic, strong) UIColor *noColor;
@property (nonatomic, strong) UIImage *yesIcon;
@property (nonatomic, strong) UIImage *noIcon;
@property (nonatomic, strong) UIImage *maybeIcon;

@end

@implementation EventCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.yesColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
    self.maybeColor = [UIColor colorWithRed:0.58f green:0.58f blue:0.58f alpha:1.0];
    self.noColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f];
    self.yesIcon = [UIImage imageNamed:@"YesIcon"];
    self.maybeIcon = [UIImage imageNamed:@"MaybeIcon"];
    self.noIcon = [UIImage imageNamed:@"NoIcon"];
    
    self.attendanceIcon.layer.cornerRadius = 10.0;
    self.attendanceIcon.layer.masksToBounds = YES;
    
    [self setUtilityButtons];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"userAttendanceStatus"]) {
        [self setAttendanceStatus];
    }
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
    if (event.coverPhotoURL) {
        [self.eventImage setImageWithURL:event.coverPhotoURL];
    } else {
        self.eventImage.image = nil;
    }

    [self setAttendanceStatus];
    [self.event addObserver:self forKeyPath:@"userAttendanceStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setAttendanceStatus
{
    UIImage *iconImage;
    UIColor *backgroundColor;
    switch (self.event.userAttendanceStatus) {
        case EventAttendanceYes:
            iconImage = self.yesIcon;
            backgroundColor = self.yesColor;
            break;
        case EventAttendanceMaybe:
            iconImage = self.maybeIcon;
            backgroundColor = self.maybeColor;
            break;
        case EventAttendanceNo:
            iconImage = self.noIcon;
            backgroundColor = self.noColor;
            break;
        default:
            break;
    }
    
    if (iconImage) {
        self.attendanceIcon.image = iconImage;
        self.attendanceIcon.backgroundColor = backgroundColor;
        self.attendanceIcon.alpha = 0.8;
        self.attendanceIcon.tintColor = [UIColor whiteColor];
        self.attendanceIcon.image = [self.attendanceIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)setUtilityButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    [rightUtilityButtons sw_addUtilityButtonWithColor:self.yesColor
                                                title:@"Yes"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:self.maybeColor
                                                title:@"Maybe"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:self.noColor
                                                title:@"No"];
    
    self.rightUtilityButtons = rightUtilityButtons;
}

@end
