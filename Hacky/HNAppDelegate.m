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
@synthesize reloadButton;
@synthesize loadTimer;
@synthesize markAsReadMenuItem;
@synthesize markAsUnreadMenuItem;
@synthesize connectionController;
@synthesize splitView;
@synthesize commentsViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSApp setDelegate:self];
  
  _window.titleBarHeight = 50.0;
  _window.trafficLightButtonsLeftMargin = 18;
  
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
  
  spinner = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(titleBarView.frame.size.width - 14 - 19, 16, 15, 15)];
  spinner.autoresizingMask = NSViewMinXMargin;
  [spinner setStyle:NSProgressIndicatorSpinningStyle];
  [spinner setUsesThreadedAnimation:YES];
  [spinner setHidden:YES];
  [titleBarView addSubview:spinner];
  
  reloadButton = [[NSButton alloc] initWithFrame:CGRectMake(titleBarView.frame.size.width - 16 - 19, 14, 20, 20)];
  reloadButton.autoresizingMask = NSViewMinXMargin;
  [reloadButton setBordered:NO];
  [reloadButton setButtonType:NSMomentaryChangeButton];
  [reloadButton setImagePosition:NSImageOnly];
  [reloadButton setImage:[NSImage imageNamed:@"reload"]];
  [reloadButton setTarget:self];
  [reloadButton setAction:@selector(didClickReloadButton:)];
  [titleBarView addSubview:reloadButton];
  
  NSView* contentView = [_window contentView];
  
  splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 30, contentView.frame.size.width, contentView.frame.size.height- 30)];
  splitView.dividerStyle = NSSplitViewDividerStyleThin;
  [splitView setVertical:YES];
  splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [contentView addSubview:splitView];
  
  listViewController = [[HNListViewController alloc] init];
  NSView *listView = listViewController.view;
//  [listView setFrame:CGRectMake(0, 60, splitView.frame.size.width / 2, splitView.frame.size.height)];
  [splitView addSubview:listView];

  commentsViewController = [[HNCommentsViewController alloc] init];
  NSView *commentsView = commentsViewController.view;
//  [commentsView setFrame:CGRectMake(0, 0, splitView.frame.size.width / 2, splitView.frame.size.height)];
  [splitView addSubview:commentsView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldLoadStories:) name:@"shouldLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadStories:) name:@"didLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldSetTitleBadge:) name:@"shouldSetTitleBadge" object:nil];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWake:) name:NSWorkspaceDidWakeNotification object:nil];
  
  [self shouldSetTitleBadge:nil];
  
  [self observeReachability];
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

- (void)didClickReloadButton:(id)sender
{
  [self load];
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
  [reloadButton setHidden:YES];
  [spinner setHidden:NO];
  [spinner startAnimation:self];
  
  connectionController = [HNConnectionController connectionWithIdentifier:@"stories"];
  
  if (loadTimer)
    [loadTimer invalidate];
  
  loadTimer = [NSTimer timerWithTimeInterval:5 * 60 target:self selector:@selector(load) userInfo:nil repeats:NO];
  [[NSRunLoop currentRunLoop] addTimer:loadTimer forMode:NSRunLoopCommonModes];
}

- (void)didLoadStories:(NSNotification*)aNotification
{
  [reloadButton setHidden:NO];
  [spinner setHidden:YES];
  [spinner stopAnimation:self];
}

- (IBAction)didClickMarkAllAsReadButton:(id)sender {
  [listViewController markAllAsRead];
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

@end
