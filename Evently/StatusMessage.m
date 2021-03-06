//
//  StatusMessage.m
//  Evently
//
//  Created by Ning Liang on 4/26/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "StatusMessage.h"
#import "PubNub.h"

@implementation StatusMessage

- (NSString *)serializeMessage {
    return [NSString stringWithFormat:@"[\"%@\", \"%@\", \"%@\", %f]",
            self.userFacebookID,
            [self.userFullName stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
            [self.text stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
            [self.date timeIntervalSince1970]
            ];
}

+ (StatusMessage *)deserializeMessage:(NSArray *)parts {    
    StatusMessage *message = [[StatusMessage alloc] init];
    message.userFacebookID = parts[0];
    message.userFullName = parts[1];
    message.text = parts[2];
    message.sender = message.userFullName;
    
    NSTimeInterval interval = [parts[3] intValue];
    message.date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return message;
}

+ (StatusMessage *)statusMessageWithText:(NSString *)text userFacebookID:(NSString *)userFacebookID userFullName:(NSString *)userFullName date:(NSDate *)date {
    StatusMessage *message = [[StatusMessage alloc] init];
    message.text = text;
    message.userFacebookID = userFacebookID;
    message.userFullName = userFullName;
    message.sender = userFullName;
    message.date = date;
    return message;
}

+ (void)updateStatusForUser:(User *)user event:(Event *)event text:(NSString *)text {
    StatusMessage *statusMessage = [StatusMessage statusMessageWithText:text userFacebookID:user.facebookID userFullName:user.name date:[NSDate date]];
    [PubNub sendMessage:[statusMessage serializeMessage] toChannel:event.statusChannel compressed:YES];
}

+ (void)getStatusesForEvent:(Event *)event withCompletion:(void (^)(NSArray *statusMessages, NSError *error))block {
    [PubNub requestFullHistoryForChannel:event.statusChannel withCompletionBlock:^(NSArray *pnMessages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
        if (error) {
            NSLog(@"Failed to replay channel: %@", [error description]);
            block(nil, error);
        } else {
            NSMutableArray *statusMessages = [[NSMutableArray alloc] init];
            for (PNMessage *pnMessage in pnMessages) {
                StatusMessage *message = [StatusMessage deserializeMessage:pnMessage.message];
                [statusMessages addObject:message];
            }
            block(statusMessages, nil);
        }
    }];
}

+ (void)latestStatusForEvent:(Event *)event withCompletion:(void (^)(StatusMessage *statusMessage, NSError *error))block {
    PNDate *from = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSince1970:0]];
    [PubNub requestHistoryForChannel:event.statusChannel from:from limit:1 reverseHistory:YES withCompletionBlock:^(NSArray *pnMessages, PNChannel *pnChannel, PNDate *startDate, PNDate *endDate, PNError *error) {
        if (error) {
            NSLog(@"Failed to replay channel: %@", [error description]);
            block(nil, error);
        } else {
            if (pnMessages.count == 1) {
                StatusMessage *message = [StatusMessage deserializeMessage:((PNMessage *)pnMessages[0]).message];
                block(message, nil);
            } else {
                block(nil, nil);
            }
        }
    }];
}

@end
