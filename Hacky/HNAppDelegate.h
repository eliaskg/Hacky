//
//  HNAppDelegate.h
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HNConstants.h"
#import "HNStory.h"
#import "HNCategorySelector.h"
#import "HNSplitView.h"
#import "Reachability.h"
#import "INAppStoreWindow.h"
#import "HNListViewController.h"
#import "HNCommentsViewController.h"
#import "HNConnectionController.h"
#import "NSWindow+FullScreen.h"

@class HNListViewController;
@class HNCommentsViewController;

@interface HNAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate>
{
  IBOutlet INAppStoreWindow* window;
  NSString* category;
  BOOL iCloudIsReady;
  HNCategorySelector* categorySelector;
  HNListViewController* listViewController;
  NSTimer* loadTimer;
  IBOutlet NSButton* markAllAsReadButton;
  IBOutlet NSMenuItem* markAsReadMenuItem;
  IBOutlet NSMenuItem* markAsUnreadMenuItem;
  IBOutlet NSMenuItem* addFavoritesMenuItem;
  IBOutlet NSMenuItem* deleteFavoritesMenuItem;
  IBOutlet NSMenuItem* fullScreenMenuItem;
  HNConnectionController* connectionController;
  NSSplitView* splitView;
  HNCommentsViewController* commentsViewController;
  BOOL didLoadStories;
  
  NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (assign) IBOutlet INAppStoreWindow* window;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, assign) BOOL iCloudIsReady;
@property (nonatomic, retain) HNCategorySelector* categorySelector;
@property (nonatomic, retain) HNListViewController* listViewController;
@property (nonatomic, retain) NSTimer* loadTimer;
@property (nonatomic, retain) IBOutlet NSButton* markAllAsReadButton;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsReadMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsUnreadMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* addFavoritesMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* deleteFavoritesMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* fullScreenMenuItem;
@property (nonatomic, retain) HNConnectionController* connectionController;
@property (nonatomic, retain) NSSplitView* splitView;
@property (nonatomic, retain) HNCommentsViewController* commentsViewController;
@property (nonatomic, assign) BOOL didLoadStories;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (IBAction)didClickReloadMenuItem:(id)sender;
- (IBAction)didClickMarkAllAsReadButton:(id)sender;
- (IBAction)didClickOpenURLButton:(id)sender;
- (IBAction)didClickViewCommentsButton:(id)sender;
- (IBAction)didClickCopyButton:(id)sender;
- (IBAction)didClickCopyURLButton:(id)sender;
- (IBAction)didClickInstapaperButton:(id)sender;
- (IBAction)didClickPocketButton:(id)sender;
- (IBAction)didClickTweetButton:(id)sender;
- (IBAction)didClickMarkAsReadButton:(id)sender;
- (IBAction)didClickMarkAsUnreadButton:(id)sender;
- (IBAction)didClickFullScreenButton:(id)sender;

+ (HNAppDelegate*)sharedAppDelegate;

@end
