//
//  UserImageCollectionViewCell.m
//  Evently
//
//  Created by Ning Liang on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "UserImageCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface UserImageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end

@implementation UserImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUserImageURL:(NSURL *)userImageURL {
    _userImageURL = userImageURL;
    [self.userImageView setImageWithURL:userImageURL];
    self.userImageView.layer.cornerRadius = 25.0;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
