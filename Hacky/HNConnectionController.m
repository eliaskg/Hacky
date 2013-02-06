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
@synthesize notification;
@synthesize networkOperation;

- (id)initWithIdentifier:(NSString*)anIdentifier
{
  self = [super init];
  if (self) {
    identifier = anIdentifier;
    
    [self setRoute];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com"]];
    
    networkOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [networkOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      [[NSNotificationCenter defaultCenter] postNotificationName:notification object:operation.responseString];
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"Failure"); 
    }];
  
    [networkOperation start];
  }
  
  return self;
}

- (void)setRoute
{
  if ([identifier isEqualToString:@"topics"]) {
    url          = @"http://hn-crawler.herokuapp.com/new";
    notification = @"didLoadTopics";
  }
  else if ([identifier isEqualToString:@"stories"]) {
    url          = @"http://news.ycombinator.com";
    notification = @"didLoadStories";
  }
}

- (void)cancel
{
  [networkOperation cancel];
}

+ (id)connectionWithIdentifier:(NSString*)anIdentifier
{
  return [[HNConnectionController alloc] initWithIdentifier:anIdentifier];
}

@end
