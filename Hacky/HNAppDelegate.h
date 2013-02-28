//
//  HNAppDelegate.h
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HNConstants.h"
#import "HNSplitView.h"
#import "Reachability.h"
#import "INAppStoreWindow.h"
#import "HNListViewController.h"
#import "HNCommentsViewController.h"
#import "HNConnectionController.h"
#import "NSWindow+FullScreen.h"

@class HNListViewController;

@interface HNAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate>
{
  IBOutlet INAppStoreWindow* window;
  NSTextField* titleLabel;
  HNListViewController* listViewController;
  NSProgressIndicator* spinner;
  NSTimer* loadTimer;
  IBOutlet NSMenuItem* markAsReadMenuItem;
  IBOutlet NSMenuItem* markAsUnreadMenuItem;
  IBOutlet NSMenuItem* fullScreenMenuItem;
  HNConnectionController* connectionController;
  NSSplitView* splitView;
  HNCommentsViewController* commentsViewController;
  BOOL didLoadStories;
}

@property (assign) IBOutlet INAppStoreWindow* window;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) HNListViewController* listViewController;
@property (nonatomic, retain) NSProgressIndicator* spinner;
@property (nonatomic, retain) NSTimer* loadTimer;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsReadMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsUnreadMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* fullScreenMenuItem;
@property (nonatomic, retain) HNConnectionController* connectionController;
@property (nonatomic, retain) NSSplitView* splitView;
@property (nonatomic, retain) HNCommentsViewController* commentsViewController;
@property (nonatomic, assign) BOOL didLoadStories;

- (IBAction)didClickReloadMenuItem:(id)sender;
- (IBAction)didClickMarkAllAsReadButton:(id)sender;
- (IBAction)didClickOpenURLButton:(id)sender;
- (IBAction)didClickViewCommentsButton:(id)sender;
- (IBAction)didClickCopyButton:(id)sender;
- (IBAction)didClickCopyURLButton:(id)sender;
- (IBAction)didClickInstapaperButton:(id)sender;
- (IBAction)didClickTweetButton:(id)sender;
- (IBAction)didClickMarkAsReadButton:(id)sender;
- (IBAction)didClickMarkAsUnreadButton:(id)sender;
- (IBAction)didClickFullScreenButton:(id)sender;

@end
