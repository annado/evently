//
//  MessagesViewController.m
//  Evently
//
//  Created by Liron Yahdav on 4/26/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "MessagesViewController.h"
#import "JSMessage.h"
#import "StatusMessage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MessagesViewController ()

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"Statuses";
    self.messageInputView.textView.placeHolder = @"Share your status";
    self.sender = [User currentUser].name;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self scrollToBottomAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *pnMessage) {
        NSString *channel = pnMessage.channel.name;
        if (self.event && [channel isEqualToString:self.event.statusChannel.name]) {
            [self processMessage:[StatusMessage deserializeMessage:pnMessage.message]];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
}

- (void)processMessage:(StatusMessage *)statusMessage {
    [self.messages addObject:statusMessage];
    [self reloadData:YES];
}

- (void)setEvent:(Event *)event {
    _event = event;
    [StatusMessage getStatusesForEvent:event withCompletion:^(NSArray *statusMessages, NSError *error) {
        self.messages = [statusMessages mutableCopy];
        [self reloadData:NO];
    }];
}

- (void)reloadData:(BOOL)animated {
    [self.tableView reloadData];
    [self scrollToBottomAnimated:animated];
}

#pragma mark - JSMessagesViewDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self finishSend];
    [StatusMessage updateStatusForUser:[User currentUser] event:self.event text:text];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    StatusMessage *message = (StatusMessage *)self.messages[indexPath.row];
    if ([message.userFacebookID isEqualToString:[User currentUser].facebookID]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath {
    StatusMessage *message = (StatusMessage *)self.messages[indexPath.row];
    if ([message.userFacebookID isEqualToString:[User currentUser].facebookID]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    } else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
}

- (JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    } else {
        cell.bubbleView.textView.textColor = [UIColor blackColor];
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
}

#pragma mark - JSMessagesViewDataSource

- (id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.row];
}

// Avatar is always rendered as a 50 px circle
- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    UIImageView *imageView = [[UIImageView alloc] init];
    StatusMessage *message = self.messages[indexPath.row];

    [imageView setImageWithURL:[User avatarURL:message.userFacebookID]];
    imageView.layer.cornerRadius = 25;
    imageView.clipsToBounds = YES;
    imageView.layer.borderColor = [UIColor colorWithRed:242.0/255 green:133.0/255 blue:0 alpha:0.6].CGColor;
    imageView.layer.borderWidth = 3.0;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return imageView;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

@end
