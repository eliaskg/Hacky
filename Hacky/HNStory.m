//
//  HNStory.m
//  Hacky
//
//  Created by Elias Klughammer on 06.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNStory.h"

@implementation HNStory

@synthesize storyId;
@synthesize title;
@synthesize points;
@synthesize createdAt;
@synthesize comments;
@synthesize url;
@synthesize isRead;

- (HNStory*)initWithDictionary:(NSMutableDictionary*)dictionary
{
  self = [super init];
  
  if (self) {
    storyId   = [dictionary valueForKey:@"id"];
    title     = [dictionary valueForKey:@"title"];
    points    = [dictionary valueForKey:@"points"];
    comments  = [dictionary valueForKey:@"comments"];
    createdAt = [dictionary valueForKey:@"createdAt"];
    url       = [dictionary valueForKey:@"url"];
  }
  
  return self;
}

@end
