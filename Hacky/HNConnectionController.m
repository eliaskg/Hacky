//
//  HNConnectionController.m
//  Hacky
//
//  Created by Elias Klughammer on 18.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNConnectionController.h"
#import "HNAppDelegate.h"

NSString * const HNConnectionControllerDidRaiseConnectionFailureNotification = @"didRaiseConnectionFailure";
	NSString * const HNConnectionControllerDidRaiseConnectionFailureErrorKey = @"didRaiseConnectionFailureErrorKey";
NSString * const HNConnectionControllerDidLoadStoriesNotification = @"didLoadStories";
NSString * const HNConnectionControllerDidLoadCommentsNotification = @"didLoadComments";
NSString * const HNConnectionControllerDidLoadFavoritesNotification = @"didLoadFavorites";
  NSString * const HNConnectionControllerDidLoadResultsKey = @"didLoadResults";

@implementation HNConnectionController

@synthesize identifier;
@synthesize url;
@synthesize method;
@synthesize params;
@synthesize notification;
@synthesize networkOperation;

- (id)initWithIdentifier:(NSString*)anIdentifier
{
  self = [super init];
  if (self) {
    identifier = anIdentifier;
  }
  
  return self;
}

- (void)setRoute
{
  if ([identifier isEqualToString:@"Top"]) {
    url          = @"http://news.ycombinator.com/";
    notification = HNConnectionControllerDidLoadStoriesNotification;
    method       = @"GET";
  }
  else if ([identifier isEqualToString:@"comments"]) {
    url          = @"http://news.ycombinator.com/item";
    notification = HNConnectionControllerDidLoadCommentsNotification;
    method       = @"GET";
  }
  else if ([identifier isEqualToString:@"New"]) {
    url          = @"http://news.ycombinator.com/newest";
    notification = HNConnectionControllerDidLoadStoriesNotification;
    method       = @"GET";
  }
  else if ([identifier isEqualToString:@"Ask"]) {
    url          = @"http://news.ycombinator.com/ask";
    notification = HNConnectionControllerDidLoadStoriesNotification;
    method       = @"GET";
  }
  else if ([identifier isEqualToString:@"Favorites"]) {
    notification = HNConnectionControllerDidLoadFavoritesNotification;
  }
}

- (void)start
{
  [self setRoute];
  
  if ([identifier isEqualToString:@"Favorites"]) {
    NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    [results sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:results];
    
    return;
  }
  
  if (params) {
    if ([method isEqualToString:@"GET"]) {
      [self parseParams];
    }
    else if ([method isEqualToString:@"POST"]) {
      
    }
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
  
  networkOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  __block HNConnectionController* myself = self;
  
  [networkOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    [[NSNotificationCenter defaultCenter] postNotificationName:myself.notification object:operation.responseString];
  } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	  NSDictionary *userInfo = @{
		HNConnectionControllerDidRaiseConnectionFailureErrorKey : error,
	  };
	  [[NSNotificationCenter defaultCenter] postNotificationName:HNConnectionControllerDidRaiseConnectionFailureNotification object:myself userInfo:userInfo];
  }];
  
  [networkOperation start];
}

- (void)cancel
{
  [networkOperation cancel];
}

- (void)parseParams
{
  int i = 0;
  
  for (id key in params) {
    NSString* queryStringBegin = (i == 0) ? @"?" : @"&";
    NSString* paramValue = [params valueForKey:key];
    NSString* queryString = [NSString stringWithFormat:@"%@%@=%@", queryStringBegin, key, paramValue];
    url = [url stringByAppendingString:queryString];
    
    i++;
  }
}

+ (id)connectionWithIdentifier:(NSString*)anIdentifier
{
  HNConnectionController* connectionController = [[HNConnectionController alloc] initWithIdentifier:anIdentifier];
  [connectionController start];
  return connectionController;
}

+ (id)connectionWithIdentifier:(NSString*)anIdentifier params:(NSDictionary*)theParams
{
  HNConnectionController* connectionController = [[HNConnectionController alloc] initWithIdentifier:anIdentifier];
  [connectionController setParams:theParams];
  [connectionController start];
  return connectionController;
}

@end
