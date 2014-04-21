//
//  DateHelper.m
//  Evently
//
//  Created by Anna Do on 4/20/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (BOOL)date:(NSDate *)date isGreaterThanMinutesAgo:(NSInteger)minutes {
    NSDate *dateAgo = [NSDate dateWithTimeIntervalSinceNow:-60*minutes];
    return [date compare:dateAgo] == NSOrderedDescending;
}

+ (BOOL)dateIsOlderThanNow:(NSDate *)date {
    NSDate *now = [[NSDate alloc] init];
    return [date compare:now] == NSOrderedAscending;
}
@end
