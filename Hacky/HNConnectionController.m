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

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    networkOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
      [[NSNotificationCenter defaultCenter] postNotificationName:notification object:JSON];
    } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON) {
      [[NSNotificationCenter defaultCenter] postNotificationName:notification object:error];
      //      NSLog(@"%@", error);
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
