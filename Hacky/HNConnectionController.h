//
//  HNConnectionController.h
//  Hacky
//
//  Created by Elias Klughammer on 18.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NSArray+Reverse.h"

@interface HNConnectionController : NSObject
{
  NSString *identifier;
  NSString *url;
  NSString *method;
  NSDictionary *params;
  NSString *notification;
  AFHTTPRequestOperation *networkOperation;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) NSString *notification;
@property (nonatomic, retain) AFHTTPRequestOperation *networkOperation;

+ (id)connectionWithIdentifier:(NSString*)anIdentifier;
+ (id)connectionWithIdentifier:(NSString*)anIdentifier params:(NSDictionary*)theParams;
- (void)start;
- (void)cancel;

@end
