//
//  HNPostCell.h
//  Hacky
//
//  Created by Elias Klughammer on 19.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HNConstants.h"
#import "HNStory.h"
#import "PXListViewCell.h"
#import "HNUnreadButton.h"

@interface HNPostCell : PXListViewCell
{
  int number;
  HNStory* story;
	HNUnreadButton* unreadButton;
  NSView* contentView;
  NSTextField* numberLabel;
  NSTextField* titleLabel;
  NSTextField* metaLabel;
  NSButton* gearButton;
  NSMenu* contextMenu;
  NSMenuItem* markAsReadMenuItem;
  NSMenuItem* markAsUnreadMenuItem;
}

@property (nonatomic, assign) int number;
@property (nonatomic, retain) HNStory* story;
@property (nonatomic, retain) NSView* contentView;
@property (nonatomic, retain) NSTextField* numberLabel;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSTextField* metaLabel;
@property (nonatomic, retain) HNUnreadButton* unreadButton;
@property (nonatomic, retain) NSButton* gearButton;
@property (nonatomic, retain) NSMenu* contextMenu;
@property (nonatomic, retain) NSMenuItem* markAsReadMenuItem;
@property (nonatomic, retain) NSMenuItem* markAsUnreadMenuItem;

- (void)setStory:(HNStory*)aStory;
- (void)setNumber:(int)aNumber;

@end