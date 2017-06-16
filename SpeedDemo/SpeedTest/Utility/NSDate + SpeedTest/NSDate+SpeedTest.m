//
//  NSDate+SpeedTest.m
//  SpeedTest
//
//  Created by Anuj on 14/06/17.
//  Copyright © 2017 Anuj. All rights reserved.
//

#import "NSDate+SpeedTest.h"

@implementation NSDate (SpeedTest)

+(NSString*)convertDateIntoStorableFormate:(NSDate*)date{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy-HH:mm:ss"];
    NSString *currentDate = [dateFormat stringFromDate:date];
    return currentDate;

}
@end
