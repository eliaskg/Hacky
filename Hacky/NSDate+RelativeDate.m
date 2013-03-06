//
//  NSDate+RelativeDate.m
//  NSDate+RelativeDate (Released under MIT License)
//
//  Created by digdog on 9/23/09.
//  Copyright (c) 2009 Ching-Lan 'digdog' HUANG. http://digdog.tumblr.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "NSDate+RelativeDate.h"


@implementation NSDate (RelativeDate)

- (NSString *)relativeDate {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:self toDate:[NSDate date] options:0];
    
    NSArray *selectorNames = [NSArray arrayWithObjects:@"year", @"month", @"week", @"day", @"hour", @"minute", @"second", nil];
    
    for (NSString *selectorName in selectorNames) {
        SEL currentSelector = NSSelectorFromString(selectorName);
        NSMethodSignature *currentSignature = [NSDateComponents instanceMethodSignatureForSelector:currentSelector];
        NSInvocation *currentInvocation = [NSInvocation invocationWithMethodSignature:currentSignature];
        
        [currentInvocation setTarget:components];
        [currentInvocation setSelector:currentSelector];
        [currentInvocation invoke];
        
        NSInteger relativeNumber;
        [currentInvocation getReturnValue:&relativeNumber];
        
        if (relativeNumber && relativeNumber != INT32_MAX) {
            if (relativeNumber > 1) {
                return [NSString stringWithFormat:@"%d %@s ago", relativeNumber, NSLocalizedString(selectorName, nil)];
            } else {
                return [NSString stringWithFormat:@"%d %@ ago", relativeNumber, NSLocalizedString(selectorName, nil)];
            }
        }
    }
    
    return @"now";
}

@end
//