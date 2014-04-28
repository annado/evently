//
//  EventNowCell.m
//  Evently
//
//  Created by Ning Liang on 4/15/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "EventNowCell.h"
#import "UserEventLocation.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface EventNowCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIView *blurView;

@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@property (weak, nonatomic) IBOutlet UILabel *checkedInCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendingCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkedInUserImage1;
@property (weak, nonatomic) IBOutlet UIImageView *checkedInUserImage2;
@property (weak, nonatomic) IBOutlet UIImageView *checkedInUserImage3;
@property (weak, nonatomic) IBOutlet UIImageView *checkedInUserImage4;

@property (nonatomic, strong) NSArray *checkedInUserImages;

@end

@implementation EventNowCell

- (void)awakeFromNib
{
    // Initialization code
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"h:mm a";
    
    self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImage.layer.masksToBounds = YES;
    
    self.checkedInUserImages = @[self.checkedInUserImage1, self.checkedInUserImage2, self.checkedInUserImage3, self.checkedInUserImage4];
    
    for (UIImageView *imageView in self.checkedInUserImages) {
        imageView.layer.cornerRadius = 20.0;
        imageView.layer.masksToBounds = YES;
    }

    [self setBlurView];
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
    if (_event.coverPhotoURL) {
        [self.coverImage setImageWithURL:event.coverPhotoURL];
    } else {
        self.coverImage.image = [UIImage imageNamed:@"EventPlaceholder"];
    }
    
    self.attendingCountLabel.text = [NSString stringWithFormat:@"%i", (int)[event.attendingUsers count]];
}

- (void)setBlurView {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.blurView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [self.blurView.layer insertSublayer:gradient atIndex:0];
}

@end
