//
//  UserCheckedInCell.m
//  Evently
//
//  Created by Anna Do on 4/15/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserCheckedInCell.h"
#import "EventCheckin.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface UserCheckedInCell ()
@property (weak, nonatomic, readonly) IBOutlet TTTAttributedLabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@end

@implementation UserCheckedInCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCheckin:(EventCheckin *)checkin
{
    _checkin = checkin;

    self.avatarImageView.layer.cornerRadius = 20;

    NSString *name = _checkin.user.name;
    NSString *text = [NSString stringWithFormat:@"%@ checked in at 9:36pm", name];
    [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
    self.textLabel.textColor = [UIColor darkGrayColor];
    NSRange r = [text rangeOfString:name];
    self.textLabel.text = text;
    [self.textLabel addLinkToURL:[NSURL URLWithString:@"action://show-help"] withRange:r];
}

@end
