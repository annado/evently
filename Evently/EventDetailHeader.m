//
//  EventDetailHeader.m
//  Evently
//
//  Created by Anna Do on 4/13/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "EventDetailHeader.h"

@interface EventDetailHeader ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation EventDetailHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	UIView *containerView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
	containerView.frame = self.bounds;
	[self addSubview:containerView];
	return self;
}

- (void)setEvent:(Event *)event
{
    self.titleLabel.text = _event.name;
    if (_event.coverPhotoURL) {
        [self.imageView setImageWithURL:_event.coverPhotoURL];
    }
}

@end
