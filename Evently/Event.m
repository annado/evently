//
//  Event.m
//  Evently
//
//  Created by Ning Liang on 4/5/14.
//  Copyright (c) 2014 Evently. All rights reserved.
//

#import "Event.h"
#import "EventNotification.h"
#import "GeofenceMonitor.h"
#import "UserEventLocation.h"

const CLLocationDistance kNearDistance = 150; // meters

NSInteger AttendanceStatuses[] = { EventAttendanceYes, EventAttendanceMaybe, EventAttendanceNo, EventAttendanceNotReplied };

@interface Event ()
@property (nonatomic, strong) EventNotification *notification;
@end

@implementation Event

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });

    return dateFormatter;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _location = [Location locationWithDictionary:dictionary];
        _location.name = dictionary[@"location"];

        self.facebookID = dictionary[@"id"];
        
        _name = dictionary[@"name"];
        _description = dictionary[@"description"];

        NSDictionary *cover = dictionary[@"cover"];
        if (cover) {
            _coverPhotoURL = [NSURL URLWithString:dictionary[@"cover"][@"source"]];
        }

        NSDateFormatter *formatter = [Event dateFormatter];

        _isDateOnly = [dictionary[@"is_date_only"] boolValue];

        if (_isDateOnly) {
            [formatter setDateFormat:@"yyyy-MM-dd"];
            _date = [formatter dateFromString:dictionary[@"start_time"]];
        } else {
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
            _startTime = [formatter dateFromString:dictionary[@"start_time"]];
            _endTime = [formatter dateFromString:dictionary[@"end_time"]];
        }
        _isHappeningNow = [self computeIsHappeningNow];

        if (dictionary[@"rsvp_status"]) {
            _userAttendanceStatus = [Event attendanceStatusForRsvpString:dictionary[@"rsvp_status"]];
        }
        _attendingUsers = [[NSMutableArray alloc] init];
        _unsureUsers = [[NSMutableArray alloc] init];
        _declinedUsers = [[NSMutableArray alloc] init];
        _notRepliedUsers = [[NSMutableArray alloc] init];

        if (dictionary[@"invited"] && dictionary[@"invited"][@"data"]) {
            for (NSDictionary *userDictionary in dictionary[@"invited"][@"data"]) {
                User *user = [[User alloc] initWithDictionary:userDictionary];
                NSString *status = userDictionary[@"rsvp_status"];
                if ([status isEqualToString:@"attending"]) {
                    [_attendingUsers addObject:user];
                } else if ([status isEqualToString:@"unsure"]) {
                    [_unsureUsers addObject:user];
                } else if ([status isEqualToString:@"declined"]) {
                    [_declinedUsers addObject:user];
                } else if ([status isEqualToString:@"not_replied"]) {
                    [_notRepliedUsers addObject:user];
                } else {
                    NSLog(@"Invalid rsvpStatus: %@", status);
                }
            }
        }

        _notification = [[EventNotification alloc] initWithEvent:self];
    }
    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return ([key isEqual:@"userAttendanceStatus"]) ? NO : YES;
}

- (void)setFacebookID:(NSString *)facebookID {
    _facebookID = facebookID;
    _locationChannel = [PNChannel channelWithName:[NSString stringWithFormat:@"%@_location", self.facebookID]];
    _statusChannel = [PNChannel channelWithName:[NSString stringWithFormat:@"%@_status", self.facebookID]];
}

// TODO properly handle errors
+ (void)eventsForUser:(User *)user
           withStatus:(NSInteger)queryStatus
           withIncludeAttendees:(BOOL)includeAttendees
           withCompletion:(void (^)(NSArray *events, NSError *error))block {

    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    NSMutableSet *pendingEventRequests = [[NSMutableSet alloc] init];

    for (NSInteger i = 0; i < 4; i++) {

        NSInteger attendanceStatus = AttendanceStatuses[i];
        if ((queryStatus & attendanceStatus) > 0) {

            NSString *format = @"/%@/events/%@?fields=id,cover,description,end_time,location,name,start_time,venue,rsvp_status";
            if (includeAttendees && attendanceStatus != EventAttendanceNotReplied) {
                format = [format stringByAppendingString:@",invited"];
            }

            NSString *path = [NSString stringWithFormat:format, user[@"facebookID"], [Event suffixForStatus:attendanceStatus]];

            FBRequest *eventRequest = [FBRequest requestForGraphPath:path];
            [pendingEventRequests addObject:eventRequest];

            [connection addRequest:eventRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSMutableArray *events = [[NSMutableArray alloc] init];

                if (!error) {
                    for (NSDictionary *dictionary in result[@"data"]) {
                        Event *event = [[Event alloc] initWithDictionary:dictionary];
                        [events addObject:event];
                    }
                } else {
                    NSLog(@"Error requesting events at %@: %@", path, [error description]);
                }

                // critical section
                [lock lock];
                [allEvents addObjectsFromArray:events];
                [pendingEventRequests removeObject:eventRequest];
                [lock unlock];

                if ([pendingEventRequests count] == 0) {
                    block(allEvents, error);
                }
            }];
        }
    }

    [connection start];
}

+ (void)eventForFacebookID:(NSString *)facebookID withIncludeAttendees:(BOOL)includeAttendees withCompletion:(void (^)(Event *event, NSError *error))block {

    NSString *format = @"/%@?fields=id,cover,description,end_time,location,name,start_time,venue";
    if (includeAttendees) {
        format = [format stringByAppendingString:@",invited"];
    }

    NSString *path = [NSString stringWithFormat:format, facebookID];

    [FBRequestConnection startWithGraphPath:path completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            Event *event = [[Event alloc] initWithDictionary:result];
            block(event, error);
        } else {
            NSLog(@"Error requesting events: %@", [error description]);
            block(nil, error);
        }
    }];

}

- (BOOL)computeIsHappeningNow {
    if (_date) {
        return [self isToday:_date];
    } else {
        NSDate *twoHoursBeforeStart = [_startTime dateByAddingTimeInterval:-60*60*2];
        NSDate *now = [NSDate date];
        // TODO: also check for equality on start or end time
        NSDate *endDate = _endTime != nil ? _endTime : [_startTime dateByAddingTimeInterval:60*60*2];
        return ([twoHoursBeforeStart compare:now] == NSOrderedAscending && [endDate compare:now] == NSOrderedDescending);
    }
}

- (BOOL)isToday:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [today isEqualToDate:otherDate];
}

+ (NSString *)suffixForStatus:(NSInteger)status {
    switch (status) {
        case EventAttendanceYes: return @"attending";
        case EventAttendanceMaybe: return @"maybe";
        case EventAttendanceNo: return @"declined";
        case EventAttendanceNotReplied: return @"not_replied";
        default:
            NSAssert(NO, @"Invalid status: %ld", (long)status);
            return nil;
    }
}

+ (NSInteger)attendanceStatusForRsvpString:(NSString *)rsvpString {
    if ([rsvpString isEqualToString:@"attending"]) {
        return EventAttendanceYes;
    } else if ([rsvpString isEqualToString:@"unsure"]) {
        return EventAttendanceMaybe;
    } else if ([rsvpString isEqualToString:@"declined"]) {
        return EventAttendanceNo;
    } else if ([rsvpString isEqualToString:@"not_replied"]) {
        return EventAttendanceNotReplied;
    } else {
        NSLog(@"Invalid rsvpString: %@", rsvpString);
        return -1;
    }
}

- (NSString *)displayDate {
    NSString *date;
    if (_startTime) {
        date = [NSDateFormatter localizedStringFromDate:_startTime
                                                        dateStyle:NSDateFormatterLongStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    } else if (_date) {
        date = [NSDateFormatter localizedStringFromDate:_date
                                              dateStyle:NSDateFormatterLongStyle
                                              timeStyle:NSDateFormatterNoStyle];
    }
    return date;
}

- (void)setUserAttendanceStatus:(NSInteger)userAttendanceStatus
{
    NSString *path = [NSString stringWithFormat:@"/%@/%@", _facebookID, [Event suffixForStatus:userAttendanceStatus]];
    [self willChangeValueForKey:@"userAttendanceStatus"];
    if (path) {
        [FBRequestConnection startWithGraphPath:path
                                     parameters:nil
                                     HTTPMethod:@"POST"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  NSLog(@"updatedRSVP to: %@", path);
                                  _userAttendanceStatus = userAttendanceStatus;
                                  [self didChangeValueForKey:@"userAttendanceStatus"];

                                  if (error) {
                                      NSLog(@"failed: %@", error);
                                  }
                              }];
    }
}

- (NSString *)displayUserAttendanceStatus {
    switch (self.userAttendanceStatus) {
        case EventAttendanceYes:
            return @"Yes";
        case EventAttendanceMaybe:
            return @"Maybe";
        case EventAttendanceNo:
            return @"No";
        case EventAttendanceNotReplied:
            return @"Not replied";
    }

    return nil;
}

- (void)checkinUser:(User *)user {
    [UserEventLocation user:user didArriveAtEvent:self withCompletion:nil];
}

+ (void)addGeofencesForEvents:(NSArray *)events {
    if(![[GeofenceMonitor sharedInstance] checkLocationManager]) {
        return;
    }

    for (Event *event in events) {
        if (event.location.latLon) {
            NSMutableDictionary * fenceDict = [NSMutableDictionary new];
            [fenceDict setValue:event.facebookID forKey:@"identifier"];
            [fenceDict setValue:@(event.location.latLon.coordinate.latitude) forKey:@"latitude"];
            [fenceDict setValue:@(event.location.latLon.coordinate.longitude) forKey:@"longitude"];
            [fenceDict setValue:@(kNearDistance) forKey:@"radius"];
            [[GeofenceMonitor sharedInstance] addGeofence:fenceDict];
        }
    }
}

@end
