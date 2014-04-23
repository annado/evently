//
//  MapAnnotationView.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//
#import "UIImageView+AFNetworking.h"
#import "EventAttendeeAnnotationView.h"
#import "EventAttendeeAnnotation.h"

@interface EventAttendeeAnnotationView ()
@end

@implementation EventAttendeeAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Set the frame size to the appropriate values.
        CGRect myFrame = self.frame;
        myFrame.size.width = 50;
        myFrame.size.height = 50;
        self.frame = myFrame;
        
        // The opaque property is YES by default. Setting it to
        // NO allows map content to show through any unrendered parts of your view.
        self.opaque = NO;

        // Pull in nib
        UIView *containerView = [[NSBundle mainBundle] loadNibNamed:@"EventAttendeeAnnotationView" owner:self options:nil][0];
        containerView.frame = self.bounds;
        [self addSubview:containerView];
        
        [self setAvatarStyle];
    }
    return self;
}

- (void)setAvatarStyle
{
    self.imageView.layer.cornerRadius = 25;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderColor = [UIColor colorWithRed:242.0/255 green:133.0/255 blue:0 alpha:0.6].CGColor;
    self.imageView.layer.borderWidth = 3.0;
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