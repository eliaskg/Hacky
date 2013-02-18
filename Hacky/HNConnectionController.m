//
//  HNConnectionController.m
//  Hacky
//
//  Created by Elias Klughammer on 18.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNConnectionController.h"

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
  if ([identifier isEqualToString:@"stories"]) {
    url          = @"http://news.ycombinator.com";
    notification = @"didLoadStories";
    method       = @"GET";
  }
  else if ([identifier isEqualToString:@"comments"]) {
    url          = @"http://news.ycombinator.com/item";
    notification = @"didLoadComments";
    method       = @"GET";
  }
}

- (void)start
{
  [self setRoute];
  
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
    NSLog(@"Failure");
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
