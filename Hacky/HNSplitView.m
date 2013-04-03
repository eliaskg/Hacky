//
//  HNSplitView.m
//  Hacky
//
//  Created by Elias Klughammer on 26.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNSplitView.h"

@implementation HNSplitView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect
{
  id topView = [[self subviews] objectAtIndex:0];
  NSRect topViewFrameRect = [topView frame];
  [self drawDividerInRect:NSMakeRect(topViewFrameRect.origin.x, topViewFrameRect.size.height, topViewFrameRect.size.width, [self dividerThickness] )];
}

- (void)drawDividerInRect:(NSRect)aRect {
  [HN_GRAY_LIGHTER set];
  NSRectFill(aRect);
}

@end
