//
//  NSWindow+FullScreen.m
//  Hacky
//
//  Created by Elias Klughammer on 28.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "NSWindow+FullScreen.h"

@implementation NSWindow (FullScreen)

- (BOOL)isFullScreen
{
  return (([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
}

@end
