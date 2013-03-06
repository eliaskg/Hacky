//
//  HNListViewController.h
//  Hacky
//
//  Created by Elias Klughammer on 19.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HNAppDelegate.h"
#import "HNParser.h"
#import "PXListView.h"
#import "PXListDocumentView.h"
#import "EQSTRScrollView.h"
#import "HNConnectionController.h"
#import "HNPostCell.h"

@interface HNListViewController : NSViewController <PXListViewDelegate>
{
  NSUInteger scrollIndex;
  NSUInteger selectedIndex;
  NSString* category;
  IBOutlet PXListView* listView;
  NSMutableArray* topics;
  BOOL applicationIsActive;
  BOOL isLoading;
  NSProgressIndicator* spinner;
}

@property (nonatomic, assign) NSUInteger scrollIndex;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) IBOutlet PXListView* listView;
@property (nonatomic, retain) NSMutableArray* topics;
@property (nonatomic, assign) BOOL applicationIsActive;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) NSProgressIndicator* spinner;

- (void)markAllAsRead;
- (void)setIsLoading:(BOOL)loading;

@end
