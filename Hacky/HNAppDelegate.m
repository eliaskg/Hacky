//
//  HNAppDelegate.m
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNAppDelegate.h"

@implementation HNAppDelegate

@synthesize window = _window;
@synthesize category;
@synthesize listViewController;
@synthesize categorySelector;
@synthesize loadTimer;
@synthesize markAsReadMenuItem;
@synthesize markAsUnreadMenuItem;
@synthesize fullScreenMenuItem;
@synthesize connectionController;
@synthesize splitView;
@synthesize commentsViewController;
@synthesize didLoadStories;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSApp setDelegate:self];
  
  [self checkDefaults];
  
  category = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedCategory"];
  
  _window.titleBarHeight = HN_ROW_HEIGHT;
  _window.trafficLightButtonsLeftMargin = HN_LEFT_MARGIN;
  _window.fullScreenButtonRightMargin = HN_LEFT_MARGIN;
  _window.centerFullScreenButton = YES;
  [_window setMinSize:NSMakeSize(2 * HN_MIN_MENU_WIDTH, HN_MIN_WINDOW_HEIGHT)];
  
  NSView *titleBarView = _window.titleBarView;

  categorySelector = [[HNCategorySelector alloc] init];
  [titleBarView addSubview:categorySelector];
  [categorySelector setCategory:category];
  
  NSView* contentView = [_window contentView];
  
  splitView = [[HNSplitView alloc] initWithFrame:NSMakeRect(0, 34, contentView.frame.size.width, contentView.frame.size.height- 34)];
  splitView.dividerStyle = NSSplitViewDividerStyleThin;
  [splitView setVertical:YES];
  splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  splitView.delegate = self;
  [contentView addSubview:splitView];
  
  listViewController = [[HNListViewController alloc] init];
  NSView* listView = listViewController.view;
  int listWidth = [[[NSUserDefaults standardUserDefaults] valueForKey:@"listWidth"] intValue];
  [listView setFrame:CGRectMake(0, 60, listWidth, 0)];
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
  
  if (![defaults valueForKey:@"selectedCategory"])
    [defaults setValue:@"Top" forKey:@"selectedCategory"];
  
  [defaults synchronize];
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

- (IBAction)didClickFullScreenButton:(id)sender
{
  [_window toggleFullScreen:self];
  
  NSMenuItem* menuItem = sender;
  
  if ([_window isFullScreen])
    menuItem.title = @"Exit Full Screen";
  else
    menuItem.title = @"Enter Full Screen";
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

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
  CGFloat dividerThickness = [sender dividerThickness];
  NSRect leftRect  = [[[sender subviews] objectAtIndex:0] frame];
  NSRect rightRect = [[[sender subviews] objectAtIndex:1] frame];
  NSRect newFrame  = [sender frame];
  
  leftRect.size.height = newFrame.size.height;
  leftRect.origin = NSMakePoint(0, 0);
  rightRect.size.width = newFrame.size.width - leftRect.size.width - dividerThickness;
  rightRect.size.height = newFrame.size.height;
  rightRect.origin.x = leftRect.size.width + dividerThickness;
  
  [[[sender subviews] objectAtIndex:0] setFrame:leftRect];
  [[[sender subviews] objectAtIndex:1] setFrame:rightRect];
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(double)proposedMin ofSubviewAt:(NSInteger)offset
{
  return proposedMin + HN_MIN_MENU_WIDTH;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(double)proposedMax ofSubviewAt:(NSInteger)offset
{
  return proposedMax - HN_MIN_MENU_WIDTH;
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
  }
  return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
  if (managedObjectModel != nil) {
    return managedObjectModel;
  }
  managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
  return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
	
  NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"LapTimer.sqlite"]];
	
	NSError *error = nil;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
  }
	
  return persistentStoreCoordinator;
}

#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark access to app delegate etc.
+ (HNAppDelegate*)sharedAppDelegate {
  return (HNAppDelegate*)[[NSApplication sharedApplication] delegate];
}

@end
