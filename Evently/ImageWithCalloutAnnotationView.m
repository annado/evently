//
//  MapAnnotationView.m
//  Evently
//
//  Created by Anna Do on 4/21/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//
#import "UIImageView+AFNetworking.h"
#import "ImageWithCalloutAnnotationView.h"
#import "EventAttendeeAnnotation.h"
#import "SMCalloutView.h"

@interface ImageWithCalloutAnnotationView ()
@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, strong) UILabel *calloutLabel;
@end

@implementation ImageWithCalloutAnnotationView

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
        UIView *containerView = [[NSBundle mainBundle] loadNibNamed:@"ImageWithCalloutAnnotationView" owner:self options:nil][0];
        containerView.frame = self.bounds;
        [self addSubview:containerView];
        
        [self setAvatarStyle];
        
        self.calloutView = [SMCalloutView platformCalloutView];
        self.calloutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        self.calloutLabel.font = [self.calloutLabel.font fontWithSize:12];
        self.calloutView.titleView = self.calloutLabel;
    }
    return self;
}

- (void)updateCallout {
    NSString *calloutText = nil;
    if ([self.annotation conformsToProtocol:@protocol(ImageAnnotation)]) {
        id<ImageAnnotation> imageAnnotation = (id<ImageAnnotation>)self.annotation;
        if ([imageAnnotation respondsToSelector:@selector(textForCallout)]) {
            calloutText = [imageAnnotation textForCallout];
        }
    }
    
    self.calloutLabel.text = calloutText;
    if (calloutText) {
        [self.calloutView presentCalloutFromRect:self.bounds inView:self constrainedToView:self.mapView animated:NO];
    } else {
        [self.calloutView dismissCalloutAnimated:NO];
    }
}

- (void)setAvatarStyle
{
    self.pinView.image = [UIImage imageNamed:@"PinIcon"];
    self.pinView.image = [self.pinView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.pinView.tintColor = [UIColor colorWithRed:242.0/255 green:133.0/255 blue:0 alpha:0.8];
    self.imageView.layer.cornerRadius = 19;
    self.imageView.clipsToBounds = YES;
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
