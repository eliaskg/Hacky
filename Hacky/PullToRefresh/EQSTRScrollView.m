//
//  EQSTRScrollView.m
//  ScrollToRefresh
//
// Copyright (C) 2011 by Alex Zielenski.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "EQSTRScrollView.h"
#import "EQSTRClipView.h"
#import <QuartzCore/QuartzCore.h>

#define REFRESH_HEADER_HEIGHT 34.0f

// code modeled from https://github.com/leah/PullToRefresh/blob/master/Classes/PullRefreshTableViewController.m

@interface EQSTRScrollView ()
@property (nonatomic, assign) BOOL _overRefreshView;
@property (nonatomic, retain) CALayer *_arrowLayer;
- (BOOL)overRefreshView;
- (void)createHeaderView;
- (void)viewBoundsChanged:(NSNotification*)note;

- (CGFloat)minimumScroll;

@end

@implementation EQSTRScrollView

#pragma mark - Private Properties

@synthesize _overRefreshView;
@synthesize _arrowLayer;

#pragma mark - Public Properties

@synthesize isRefreshing   = _isRefreshing;
@synthesize refreshHeader  = _refreshHeader;
@synthesize refreshBlock   = _refreshBlock;

#pragma mark - Create Header View

- (void)viewDidMoveToWindow {
	[self createHeaderView];
}

- (NSClipView *)contentView {
	NSClipView *superClipView = [super contentView];
	if (![superClipView isKindOfClass:[EQSTRClipView class]]) {
		
		// create new clipview
		NSView *documentView     = superClipView.documentView;
		
		EQSTRClipView *clipView  = [[EQSTRClipView alloc] initWithFrame:superClipView.frame];
		clipView.documentView    = documentView;
		clipView.copiesOnScroll  = NO;
		clipView.drawsBackground = NO;
		
		[self setContentView:clipView];
		
		superClipView            = [super contentView];
		
	}
	return superClipView;
}

- (void)createHeaderView {
	// delete old stuff if any
	if (self.refreshHeader) {		
		[_refreshHeader removeFromSuperview];
		_refreshHeader = nil;
	}
	
	[self setVerticalScrollElasticity:NSScrollElasticityAllowed];
	
	(void)self.contentView; // create new content view
	
	[self.contentView setPostsFrameChangedNotifications:YES];
	[self.contentView setPostsBoundsChangedNotifications:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(viewBoundsChanged:)
												 name:NSViewBoundsDidChangeNotification 
											   object:self.contentView];
	
	// add header view to clipview
	NSRect contentRect = [self.contentView.documentView frame];
	_refreshHeader = [[HNPullToRefreshHeader alloc] initWithFrame:NSMakeRect(0,
															  0 - REFRESH_HEADER_HEIGHT,
															  contentRect.size.width, 
															  REFRESH_HEADER_HEIGHT)];
	
	// set autoresizing masks
	self.refreshHeader.autoresizingMask  = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin; // stretch/center
	
	[self.contentView addSubview:self.refreshHeader];
	
	// Scroll to top
	[self.contentView scrollToPoint:NSMakePoint(contentRect.origin.x, 0)];
	[self reflectScrolledClipView:self.contentView];
}

#pragma mark - Detecting Scroll

- (void)scrollWheel:(NSEvent *)event {
	if (event.phase == NSEventPhaseEnded) {
		if (self._overRefreshView && ! self.isRefreshing) {
			[self startLoading];
		}
	}
	
	[super scrollWheel:event];
}

- (void)viewBoundsChanged:(NSNotification *)note {
	if (self.isRefreshing)
		return;
  
  self._overRefreshView = !![self overRefreshView];
	
  [_refreshHeader setProgress:[self scrollProgress]];
}

- (float)scrollProgress {
	NSClipView *clipView  = self.contentView;
	NSRect bounds         = clipView.bounds;
	
	CGFloat scrollValue   = bounds.origin.y;
	CGFloat minimumScroll = self.minimumScroll;
  
  return MAX(MIN(scrollValue / minimumScroll, 1.0), 0.0);
}

- (BOOL)overRefreshView {
  NSClipView *clipView  = self.contentView;
  NSRect bounds         = clipView.bounds;
    
  CGFloat scrollValue   = bounds.origin.y;
  CGFloat minimumScroll = self.minimumScroll;
  
  return (scrollValue <= minimumScroll);
}

- (CGFloat)minimumScroll {
	return 0 - self.refreshHeader.frame.size.height;
}

#pragma mark - Refresh

- (void)startLoading {
  [_refreshHeader startLoading];
  
	[self willChangeValueForKey:@"isRefreshing"];
	_isRefreshing            = YES;
	[self didChangeValueForKey:@"isRefreshing"];
	
	if (self.refreshBlock) {
		self.refreshBlock(self);
	}
}

- (void)stopLoading {
  [_refreshHeader stopLoading];
  
	// now fake an event of scrolling for a natural look
	[self willChangeValueForKey:@"isRefreshing"];
	_isRefreshing = NO;
	[self didChangeValueForKey:@"isRefreshing"];
	
	CGEventRef cgEvent   = CGEventCreateScrollWheelEvent(NULL,
														 kCGScrollEventUnitLine,
														 2,
														 1,
														 0);
	
	NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
	[self scrollWheel:scrollEvent];
	CFRelease(cgEvent);
}

- (void)drawRect:(NSRect)aRect
{
  aRect = [self bounds];
  
  [[NSColor whiteColor] set];
  NSBezierPath *background = [NSBezierPath bezierPathWithRect:aRect];
  [background fill];
}

@end
