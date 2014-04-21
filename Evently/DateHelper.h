//
//  DateHelper.h
//  Evently
//
//  Created by Anna Do on 4/20/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject
+ (BOOL)date:(NSDate *)date isGreaterThanMinutesAgo:(NSInteger)minutes;
+ (BOOL)dateIsOlderThanNow:(NSDate *)date;
@end
