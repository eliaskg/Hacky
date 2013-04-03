//
//  HNParser.h
//  Hacky
//
//  Created by Elias Klughammer on 06.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNStory.h"

@interface HNParser : NSObject

- (NSMutableArray*)parseStories:(NSString*)response;
- (NSMutableArray*)parseComments:(NSString*)theResponse hasURL:(BOOL)hasURL;

@end
