//
//  HNUnreadButton.m
//  Hacky
//
//  Created by Elias Klughammer on 04.12.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNUnreadButton.h"

@implementation HNUnreadButton

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBordered:NO];
    [self setButtonType:NSMomentaryChangeButton];
    [self setImagePosition:NSImageOnly];
    [self createTrackingArea];
    [self setSelected:NO];
  }
    
  return self;
}

- (void)setSelected:(BOOL)isSelected
{
  if (isSelected)
    [self setImage:[NSImage imageNamed:@"unreadSelected"]];
  else
    [self setImage:[NSImage imageNamed:@"unread"]];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
  self.alphaValue = 0.7;
}

- (void)mouseExited:(NSEvent *)theEvent
{
  self.alphaValue = 1.0;
}

- (void)createTrackingArea
{
  NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp;
  focusTrackingAreaOptions |= NSTrackingMouseEnteredAndExited;
  focusTrackingAreaOptions |= NSTrackingAssumeInside;
  focusTrackingAreaOptions |= NSTrackingInVisibleRect;
  
  NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                   options:focusTrackingAreaOptions owner:self userInfo:nil];
  [self addTrackingArea:focusTrackingArea];
}

@end
