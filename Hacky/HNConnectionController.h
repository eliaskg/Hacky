//
//  HNConnectionController.h
//  Hacky
//
//  Created by Elias Klughammer on 18.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HNConnectionController : NSObject
{
  NSString *identifier;
  NSString *url;
  NSString *notification;
  AFHTTPRequestOperation *networkOperation;
}

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *notification;
@property (nonatomic, retain) AFHTTPRequestOperation *networkOperation;

+ (id)connectionWithIdentifier:(NSString*)anIdentifier;
- (void)cancel;

@end
