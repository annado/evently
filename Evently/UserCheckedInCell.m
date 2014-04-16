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
    
    NSString *text = @"Anna Do checked in at 9:36pm";
    [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
//    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
    self.textLabel.textColor = [UIColor darkGrayColor];
    
    NSRange r = [text rangeOfString:@"Anna Do"];
    self.textLabel.text = text;
    
    [self.textLabel addLinkToURL:[NSURL URLWithString:@"action://show-help"] withRange:r];
}

@end
