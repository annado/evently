//
//  CheckinButton.m
//  Evently
//
//  Created by Anna Do on 4/14/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "CheckinButton.h"
#import "UserEventLocation.h"

@interface CheckinButton ()
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@property (nonatomic, assign) BOOL checkedIn;
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

- (void)setEvent:(Event *)event
{
    _event = event;
    [UserEventLocation user:[User currentUser] isAtEvent:_event withCompletion:^(BOOL isPresent, NSError *error) {
        self.checkedIn = isPresent;
    }];
}

- (void)setCheckedIn:(BOOL)isCheckedIn
{
    _checkedIn = isCheckedIn;
    if (_checkedIn) {
        self.checkinButton.enabled = NO;
        self.checkinButton.alpha = 0.5;
    }
}

- (IBAction)onCheckinButton:(id)sender {
    [_event checkinUser:[User currentUser]];
    self.checkedIn = YES;
}

@end
