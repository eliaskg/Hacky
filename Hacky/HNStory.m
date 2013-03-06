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

@class HNStory;

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

- (void)setIsReadInDB
{
  if (isRead)
    return;
  
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSManagedObject *cdStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
  [cdStory setValue:storyId forKey:@"id"];
  [cdStory setValue:[NSNumber numberWithBool:YES] forKey:@"isRead"];
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (void)setIsUnreadInDB
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", storyId, [NSNumber numberWithInt:1]];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  for (NSManagedObject *managedObject in results) {
    [context deleteObject:managedObject];
  }
  
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (BOOL)isReadInDB
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", storyId, [NSNumber numberWithInt:1]];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  return [results count] > 0;
}

- (BOOL)isFavoriteInDB
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", storyId];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  return [results count] > 0;
}

- (void)makeFavoriteInDB
{
  if ([self isFavoriteInDB])
    return;
  
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSManagedObject *cdStory = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:context];
  [cdStory setValue:storyId forKey:@"id"];
  [cdStory setValue:title forKey:@"title"];
  [cdStory setValue:url forKey:@"url"];
  [cdStory setValue:[NSDate new] forKey:@"createdAt"];
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (void)deleteFavoriteInDB
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", storyId];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  for (NSManagedObject *managedObject in results) {
    [context deleteObject:managedObject];
  }
  
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

@end
