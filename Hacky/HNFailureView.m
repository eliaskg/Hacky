//
//  HNFailureView.m
//  Hacky
//
//  Created by Elias Klughammer on 24.05.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNFailureView.h"

@implementation HNFailureView

- (id)init
{
  self = [super init];
  if (self) {
    self.hidden = YES;
    
    self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    
    int paddingX = 8;
    int paddingY = 6;
    
    NSTextField *labelView = [[NSTextField alloc] initWithFrame:NSMakeRect(paddingX, paddingY, 0, 0)];
    labelView.stringValue = @"No connection to Hacker News";
    [labelView setTextColor:[NSColor whiteColor]];
    [labelView setEditable:NO];
    [labelView setBezeled:NO];
    [labelView setBordered:NO];
    [labelView setBackgroundColor:[NSColor clearColor]];
    [labelView sizeToFit];
    [self setFrameSize:NSMakeSize(labelView.bounds.size.width + 2*paddingX,
                                  labelView.bounds.size.height + 2*paddingY)];
    [self addSubview:labelView];
  }
  
  return self;
}

- (void)show
{
  [self setFrameOrigin:NSMakePoint(self.superview.bounds.size.width / 2 - self.bounds.size.width / 2,
                                   self.superview.bounds.size.height / 2 - self.bounds.size.height / 2)];
  self.hidden = NO;
}

- (void)hide
{
  self.hidden = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [HN_GRAY_LIGHTER set];
  
  NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:14 yRadius:14];
  [path fill];
}

@end
