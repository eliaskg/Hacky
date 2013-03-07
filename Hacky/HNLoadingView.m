//
//  HNLoadingView.m
//  Hacky
//
//  Created by Elias Klughammer on 07.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNLoadingView.h"

@implementation HNLoadingView

@synthesize isLoading;
@synthesize spinner;

- (id)init
{
  self = [super init];
  if (self) {
    self.hidden = YES;
    
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  }
  
  return self;
}

- (void)setIsLoading:(BOOL)loading
{
  if (loading == isLoading)
    return;
  
  isLoading = loading;
  
  if (!spinner) {
    spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.bounds.size.width / 2 - 18 / 2, self.bounds.size.height / 2 - 18 / 2, 18, 18)];
    spinner.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    [spinner setStyle:NSProgressIndicatorSpinningStyle];
    [self addSubview:spinner];
  }
  
  if (isLoading)
    [spinner startAnimation:self];
  else
    [spinner stopAnimation:self];
  
  self.hidden = !isLoading;
}

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
}

@end
