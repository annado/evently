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
        UINib *nib = [UINib nibWithNibName:@"EventDetailHeader" bundle:nil];
        NSArray *nibArray = [nib instantiateWithOwner:self options:nil];
        [self addSubview:nibArray[0]];
    }
    return self;
}

- (void)setEvent:(Event *)event
{
    _event = event;
    self.titleLabel.text = _event.name;
    if (_event.coverPhotoURL) {
        [self.imageView setImageWithURL:_event.coverPhotoURL];
        self.titleLabel.layer.shadowRadius = 3.0;
    } else {
        self.titleLabel.textColor = [UIColor darkGrayColor];
        self.titleLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
    }
    
    CGRect frame = self.frame;
    frame.size.height = [self heightForView];
    self.frame = frame;
}

- (CGFloat)heightForView
{
    if (_event.coverPhotoURL) {
        return 250;
    } else {
        return 52;
    }
}

@end
