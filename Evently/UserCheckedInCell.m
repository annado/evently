//
//  UserCheckedInCell.m
//  Evently
//
//  Created by Anna Do on 4/15/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserCheckedInCell.h"
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

- (void)setUserEventLocation:(UserEventLocation *)userEventLocation;
{
    _userEventLocation = userEventLocation;

    self.avatarImageView.layer.cornerRadius = 20;

    NSString *text = [_userEventLocation displayText];
    [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.textLabel.text = text;
}

@end
