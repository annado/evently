//
//  CheckinButton.m
//  Evently
//
//  Created by Anna Do on 4/14/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "CheckinButton.h"
#import "EventCheckin.h"

@interface CheckinButton ()
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
- (IBAction)onCheckinButton:(id)sender;
@end

@implementation CheckinButton

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	UIView *containerView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
	containerView.frame = self.bounds;
	[self addSubview:containerView];

    self.checkinButton.layer.cornerRadius = 5;
	return self;
}

- (void)setButtonText:(NSString *)buttonText
{
    self.checkinButton.titleLabel.text = buttonText;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)onCheckinButton:(id)sender {
    [_event checkinCurrentUser];
}

@end
