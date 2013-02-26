//
//  HNAppDelegate.m
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNAppDelegate.h"

#define kHostName @"news.ycombinator.com"

@implementation HNAppDelegate

@synthesize window = _window;
@synthesize listViewController;
@synthesize titleLabel;
@synthesize spinner;
@synthesize loadTimer;
@synthesize markAsReadMenuItem;
@synthesize markAsUnreadMenuItem;
@synthesize connectionController;
@synthesize splitView;
@synthesize commentsViewController;
@synthesize didLoadStories;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSApp setDelegate:self];
  
  [self checkDefaults];
  
  _window.titleBarHeight = 34.0;
  _window.trafficLightButtonsLeftMargin = 18;
  _window.fullScreenButtonRightMargin = -100;
  _window.centerFullScreenButton = YES;
  
  NSView *titleBarView = _window.titleBarView;
  titleLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
  [titleLabel setEditable:NO];
  [titleLabel setBezeled:NO];
  [titleLabel setBordered:NO];
  [titleLabel setBackgroundColor:[NSColor clearColor]];
  [titleLabel setFrameOrigin:NSMakePoint((NSWidth([titleBarView bounds]) - NSWidth([titleLabel frame])) / 2,
                                         (NSHeight([titleBarView bounds]) - NSHeight([titleLabel frame])) / 2)];
  [titleLabel setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
  [titleBarView addSubview:titleLabel];
  
  spinner = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(titleBarView.frame.size.width - 14 - 19, 11, 15, 15)];
  spinner.autoresizingMask = NSViewMinXMargin;
  [spinner setStyle:NSProgressIndicatorSpinningStyle];
  [spinner setUsesThreadedAnimation:YES];
  [spinner startAnimation:self];
  [titleBarView addSubview:spinner];
  
  NSView* contentView = [_window contentView];
  
  splitView = [[HNSplitView alloc] initWithFrame:NSMakeRect(0, 30, contentView.frame.size.width, contentView.frame.size.height- 30)];
  splitView.dividerStyle = NSSplitViewDividerStyleThin;
  [splitView setVertical:YES];
  splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  splitView.delegate = self;
  [contentView addSubview:splitView];
  
  listViewController = [[HNListViewController alloc] init];
  NSView* listView = listViewController.view;
  int listWidth = [[[NSUserDefaults standardUserDefaults] valueForKey:@"listWidth"] intValue];
  [listView setFrame:CGRectMake(0, 60, listWidth, splitView.frame.size.height)];
  [splitView addSubview:listView];

  commentsViewController = [[HNCommentsViewController alloc] init];
  NSView *commentsView = commentsViewController.view;

  [splitView addSubview:commentsView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldLoadStories:) name:@"shouldLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadStories:) name:@"didLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldSetTitleBadge:) name:@"shouldSetTitleBadge" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:_window];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:_window];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWake:) name:NSWorkspaceDidWakeNotification object:nil];
  
  
  [self shouldSetTitleBadge:nil];
  
  [self observeReachability];
}

- (void)checkDefaults
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if (![defaults valueForKey:@"listWidth"])
    [defaults setValue:[NSNumber numberWithInt:400] forKey:@"listWidth"];
}

- (void)observeReachability
{
  Reachability* reach = [Reachability reachabilityWithHostname:@"news.ycombinator.com"];
  
  // set the blocks
  reach.reachableBlock = ^(Reachability*reach)
  {
    [self load];
  };
  
  [reach startNotifier];
}

- (IBAction)didClickReloadMenuItem:(id)sender;
{
  [self load];
}

- (void)shouldSetTitleBadge:(NSNotification*)aNotification
{
  NSNumber *number;
  
  if (aNotification)
    number = [aNotification object];
  else
    number = [NSNumber numberWithInt:0];
  
  NSString* titleString;
  
  if ([number isEqualTo:[NSNumber numberWithInt:0]])
    titleString = @"Hacky";
  else
    titleString = [NSString stringWithFormat:@"Hacky (%@)", number];
  
  NSView *titleBarView = _window.titleBarView;
  NSShadow *shadow = [[NSShadow alloc] init];
  [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.3]];
  [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
  // Create the attributes dictionary, you can change the font size
  // to whatever is useful to you
  NSMutableDictionary *sAttribs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [NSFont fontWithName:@"LucidaGrande" size:13],NSFontAttributeName,
                                   shadow, NSShadowAttributeName,
                                   nil];
  // Create a new attributed string with your attributes dictionary attached
  NSAttributedString *s = [[NSAttributedString alloc] initWithString:titleString attributes:sAttribs];
  // Set your text value
  [titleLabel setAttributedStringValue:s];
  [titleLabel sizeToFit];
  [titleLabel setFrameOrigin:NSMakePoint((NSWidth([titleBarView bounds]) - NSWidth([titleLabel frame])) / 2,
                                         (NSHeight([titleBarView bounds]) - NSHeight([titleLabel frame])) / 2)];
}

- (IBAction)didClickOpenURLButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickOpenURLMenuButton" object:nil];
}

- (IBAction)didClickViewCommentsButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCommentsMenuButton" object:nil];
}

- (IBAction)didClickCopyButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCopyMenuButton" object:nil];
}

- (IBAction)didClickCopyURLButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCopyURLMenuButton" object:nil];
}

- (IBAction)didClickInstapaperButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickInstapaperMenuButton" object:nil];
}

- (IBAction)didClickTweetButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickTweetMenuButton" object:nil];
}

- (IBAction)didClickMarkAsReadButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMarkAsReadMenuButton" object:nil];
}

- (IBAction)didClickMarkAsUnreadButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMarkAsUnreadMenuButton" object:nil];
}

- (void)workspaceDidWake:(NSNotification*)aNotification
{
  [self load];
}

- (void)shouldLoadStories:(NSNotification*)aNotification
{
  [self load];
}

- (void)load
{
  connectionController = [HNConnectionController connectionWithIdentifier:@"stories"];
}

- (void)setLoadTimerIsActive:(BOOL)isActive
{
  if (isActive) {
    loadTimer = [NSTimer timerWithTimeInterval:5 * 60 target:self selector:@selector(load) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:loadTimer forMode:NSRunLoopCommonModes];
  }
  else if (!isActive && loadTimer) {
    [loadTimer invalidate];
  }
}

- (void)didLoadStories:(NSNotification*)aNotification
{
  if (didLoadStories)
    return;
  
  [spinner stopAnimation:self];
  spinner.hidden = YES;
  _window.fullScreenButtonRightMargin = 18;
  
  didLoadStories = YES;
}

- (IBAction)didClickMarkAllAsReadButton:(id)sender {
  [listViewController markAllAsRead];
}

- (void)windowDidResignKey:(NSNotification*)aNotification
{
  [self setLoadTimerIsActive:YES];
}

- (void)windowDidBecomeKey:(NSNotification*)aNotification
{
  [self setLoadTimerIsActive:NO];
}

- (void)applicationDidBecomeActive:(NSNotification*)aNotification
{
  [listViewController setApplicationIsActive:YES];
}

- (void)applicationDidResignActive:(NSNotification*)aNotification
{
  [listViewController setApplicationIsActive:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
  return YES;
}

//- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(double)proposedMin ofSubviewAt:(NSInteger)offset
//{
//  NSLog(@"%d", offset);
//  return proposedMin + 60.0;
//}

@end
