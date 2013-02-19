//
//  HNAppDelegate.h
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reachability.h"
#import "INAppStoreWindow.h"
#import "HNListViewController.h"
#import "HNCommentsViewController.h"
#import "HNConnectionController.h"

@class HNListViewController;

@interface HNAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate>
{
  IBOutlet INAppStoreWindow* window;
  NSTextField* titleLabel;
  NSProgressIndicator* spinner;
  NSButton* reloadButton;
  HNListViewController* listViewController;
  NSTimer* loadTimer;
  IBOutlet NSMenuItem* markAsReadMenuItem;
  IBOutlet NSMenuItem* markAsUnreadMenuItem;
  HNConnectionController* connectionController;
  NSSplitView* splitView;
  HNCommentsViewController* commentsViewController;
}

@property (assign) IBOutlet INAppStoreWindow* window;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSProgressIndicator* spinner;
@property (nonatomic, retain) NSButton* reloadButton;
@property (nonatomic, retain) HNListViewController* listViewController;
@property (nonatomic, retain) NSTimer* loadTimer;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsReadMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem* markAsUnreadMenuItem;
@property (nonatomic, retain) HNConnectionController* connectionController;
@property (nonatomic, retain) NSSplitView* splitView;
@property (nonatomic, retain) HNCommentsViewController* commentsViewController;

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

@end
