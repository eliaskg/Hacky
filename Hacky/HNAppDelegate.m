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
@synthesize iCloudIsReady;
@synthesize listViewController;
@synthesize categorySelector;
@synthesize loadTimer;
@synthesize markAllAsReadButton;
@synthesize markAsReadMenuItem;
@synthesize markAsUnreadMenuItem;
@synthesize addFavoritesMenuItem;
@synthesize deleteFavoritesMenuItem;
@synthesize fullScreenMenuItem;
@synthesize connectionController;
@synthesize splitView;
@synthesize commentsViewController;
@synthesize didLoadStories;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize _preferencesWindowController;

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
  
  markAllAsReadButton.title = NSLocalizedString(@"MARK_ALL_AS_READ", nil);

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
  listViewController.category = category;
  [splitView addSubview:listView];

  commentsViewController = [[HNCommentsViewController alloc] init];
  NSView *commentsView = commentsViewController.view;

  [splitView addSubview:commentsView];
  
  listViewController.loadingView.isLoading = YES;
  
  markAllAsReadButton.enabled = ![category isEqualToString:@"Favorites"];
  
  [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudStatusDidChange:) name:@"iCloudStatusDidChange" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDidUpdate) name:@"iCloudDidUpdate" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectCategory:) name:@"didSelectCategory" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldLoadStories:) name:@"shouldLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetLoadingInterval) name:@"shouldResetLoadingInterval" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadStories:) name:HNConnectionControllerDidLoadStoriesNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:_window];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:_window];
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidWake:) name:NSWorkspaceDidWakeNotification object:nil];
  
  [self observeReachability];
  
  [Crashlytics startWithAPIKey:HN_CRASHLYTICS_ID];
}

- (void)checkDefaults
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if (![defaults valueForKey:@"listWidth"])
    [defaults setValue:[NSNumber numberWithInt:400] forKey:@"listWidth"];
  
  if (![defaults valueForKey:@"selectedCategory"])
    [defaults setValue:@"Top" forKey:@"selectedCategory"];
  
  if (![defaults valueForKey:@"loadingInterval"])
    [defaults setInteger:5*60 forKey:@"loadingInterval"];
  
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

- (void)didSelectCategory:(NSNotification*)aNotification
{
  category = [aNotification object];
  listViewController.category = category;
  listViewController.loadingView.isLoading = YES;
  [listViewController.listView scrollRowToVisible:0];
  [self load];
  
  markAllAsReadButton.enabled = ![category isEqualToString:@"Favorites"];
}

- (IBAction)didClickReloadMenuItem:(id)sender;
{
  [self load];
}

- (void)iCloudStatusDidChange:(NSNotification*)aNotification
{
  iCloudIsReady = YES;
  [self load];
}

- (void)iCloudDidUpdate
{
  if ([category isEqualToString:@"Favorites"])
    [self load];
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
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCopyMenuButton" object:_window.firstResponder];
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

- (IBAction)didClickAddFavoritesButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMakeFavoriteMenuButton" object:nil];
}

- (IBAction)didClickDeleteFavoritesButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickDeleteFavoriteMenuButton" object:nil];
}

- (IBAction)didClickPreferencesButton:(id)sender
{
  [self.preferencesWindowController showWindow:nil];
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

- (NSWindowController *)preferencesWindowController
{
  if (_preferencesWindowController == nil)
  {
    NSViewController *generalViewController = [[HNGeneralPreferencesViewController alloc] init];
    NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, nil];
    
    // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
    //     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];
    
    NSString *title = @"Preferences";
    
    _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
  }
  
  return _preferencesWindowController;
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
  if (iCloudIsReady)
    connectionController = [HNConnectionController connectionWithIdentifier:category];
}

- (void)resetLoadingInterval
{
  [self setLoadTimerIsActive:NO];
  [self setLoadTimerIsActive:YES];
}

- (void)setLoadTimerIsActive:(BOOL)isActive
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSInteger loadingInterval = [defaults integerForKey:@"loadingInterval"];
  
  if (loadingInterval == -1) {
    if (loadTimer)
      [loadTimer invalidate];
    
    return;
  }
  
  if (isActive) {
    loadTimer = [NSTimer timerWithTimeInterval:loadingInterval target:self selector:@selector(load) userInfo:nil repeats:YES];
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
- (NSManagedObjectContext *)managedObjectContext {
  
  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  
  if (coordinator != nil) {
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [moc performBlockAndWait:^{
      [moc setPersistentStoreCoordinator: coordinator];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
    }];
    managedObjectContext = moc;
  }
  
  return managedObjectContext;
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
  
	NSLog(@"Merging in changes from iCloud...");
  
  NSManagedObjectContext* moc = [self managedObjectContext];
  
  [moc performBlock:^{
    [moc mergeChangesFromContextDidSaveNotification:notification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDidUpdate" object:nil];
  }];
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
  if((persistentStoreCoordinator != nil)) {
    return persistentStoreCoordinator;
  }
  
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
  NSPersistentStoreCoordinator *psc = persistentStoreCoordinator;
  
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // ** Note: if you adapt this code for your own use, you MUST change this variable:
    NSString *iCloudEnabledAppID = @"com.eliasklughammer.hackernews";
    
    // ** Note: if you adapt this code for your own use, you should change this variable:
    NSString *dataFileName = @"Models.sqlite";
    
    // ** Note: For basic usage you shouldn't need to change anything else
    
    NSString *iCloudDataDirectoryName = @"Data.nosync";
    NSString *iCloudLogsDirectoryName = @"Logs";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL* applicationDocumentsDirectory = [self applicationFilesDirectory];
    NSLog(@"%@", applicationDocumentsDirectory);
    NSURL *localStore = [applicationDocumentsDirectory URLByAppendingPathComponent:dataFileName];
    NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if (iCloud) {
      NSLog(@"iCloud is working");
      
      NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent: iCloudLogsDirectoryName]];
      
      NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
      NSLog(@"dataFileName = %@", dataFileName);
      NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
      NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
      NSLog(@"iCloud = %@", iCloud);
      NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);
      
      if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
        NSError *fileSystemError;
        [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&fileSystemError];
        if(fileSystemError != nil) {
          NSLog(@"Error creating database directory %@", fileSystemError);
        }
      }
      
      NSString *iCloudData = [[[iCloud path]
                               stringByAppendingPathComponent:iCloudDataDirectoryName]
                              stringByAppendingPathComponent:dataFileName];
      
      NSLog(@"iCloudData = %@", iCloudData);
      
      NSMutableDictionary *options = [NSMutableDictionary dictionary];
      [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
      [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
      [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
      [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
      
      [psc lock];
      
      [psc addPersistentStoreWithType:NSSQLiteStoreType
                        configuration:nil
                                  URL:[NSURL fileURLWithPath:iCloudData]
                              options:options
                                error:nil];
      
      [psc unlock];
    }
    else {
      NSLog(@"iCloud is NOT working - using a local store");
      
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
      NSError *error = nil;
      
      NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
      
      if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
          ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
          [[NSApplication sharedApplication] presentError:error];
        }
      } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
          // Customize and localize this error.
          NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
          
          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
          error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
          
          [[NSApplication sharedApplication] presentError:error];
        }
      }
      
      
      
      
      NSMutableDictionary *options = [NSMutableDictionary dictionary];
      [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
      [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
      
      [psc lock];
      
      [psc addPersistentStoreWithType:NSSQLiteStoreType
                        configuration:nil
                                  URL:localStore
                              options:options
                                error:nil];
      [psc unlock];
      
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudStatusDidChange" object:self userInfo:nil];
    });
  });
  
  return persistentStoreCoordinator;
}

#pragma mark Application's Documents directory

- (NSURL *)applicationFilesDirectory
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
  return [appSupportURL URLByAppendingPathComponent:@"Hacky"];
}

#pragma mark access to app delegate etc.
+ (HNAppDelegate*)sharedAppDelegate {
  return (HNAppDelegate*)[[NSApplication sharedApplication] delegate];
}

#pragma mark -

@end
