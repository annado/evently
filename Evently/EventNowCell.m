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

@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
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
    [self.coverImage setImageWithURL:event.coverPhotoURL];
    
    self.attendingCountLabel.text = [NSString stringWithFormat:@"%i", (int)[event.attendingUsers count]];
    
    // TODO refactor this into model, use a more efficient query
//    [UserEventLocation userEventLocationsForEvent:event withCompletion:^(NSArray *userEventLocations, NSError *error) {
//        if (!error) {
//            NSInteger checkinCount = [userEventLocations count];
//            self.checkedInCountLabel.text = [NSString stringWithFormat:@"%i", checkinCount];
//            for (int i = 0; i < [self.checkedInUserImages count] && i < checkinCount; i++) {
//                UserEventLocation *userEventLocation = userEventLocations[i];
//                [checkIn[@"user"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                    User *user = (User *)object;
//                    [self.checkedInUserImages[i] setImageWithURL:[user avatarURL]];
//                }];
//            }
//        }
//    }];
    
}

@end
