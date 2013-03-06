//
//  NSArray+Reverse.h
//  Hacky
//
//  Created by Elias Klughammer on 06.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reverse)
- (NSArray*)reversedArray;
@end

@interface NSMutableArray (Reverse)
- (void)reverse;
@end

