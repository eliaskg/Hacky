//
//  HNStory.h
//  Hacky
//
//  Created by Elias Klughammer on 06.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNAppDelegate.h"

@interface HNStory : NSObject
{
  NSString* storyId;
  NSString* title;
  NSString* points;
  NSString* createdAt;
  NSString* comments;
  NSString* url;
  BOOL isRead;
}

@property (nonatomic, retain) NSString* storyId;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* points;
@property (nonatomic, retain) NSString* createdAt;
@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, assign) BOOL isRead;

- (HNStory*)initWithDictionary:(NSMutableDictionary*)dictionary;
- (void)setIsReadInDB;
- (void)setIsUnreadInDB;
- (BOOL)isReadInDB;

@end
