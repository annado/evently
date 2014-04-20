//
//  EventlyTests.m
//  EventlyTests
//
//  Created by Anna Do on 4/1/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"

@interface AppDelegate (PrivateMethodsExposedForTests)
+ (BOOL)date:(NSDate *)date isGreaterThanMinutesAgo:(NSInteger)minutes;
@end

@interface EventlyTests : XCTestCase

@end

@implementation EventlyTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDateIsGreaterThanMinutesAgo {
    NSDate *tenMinutesAgo = [NSDate dateWithTimeIntervalSinceNow:-60*10];
    XCTAssertTrue([AppDelegate date:tenMinutesAgo isGreaterThanMinutesAgo:12]);
    XCTAssertFalse([AppDelegate date:tenMinutesAgo isGreaterThanMinutesAgo:8]);
}

@end
