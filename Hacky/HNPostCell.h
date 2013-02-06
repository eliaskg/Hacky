//
//  HNPostCell.h
//  Hacky
//
//  Created by Elias Klughammer on 19.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"
#import "HNUnreadButton.h"

@interface HNPostCell : PXListViewCell
{
  NSUInteger number;
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

@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, retain) NSDictionary* topic;
@property (nonatomic, retain) NSView* contentView;
@property (nonatomic, retain) NSTextField* numberLabel;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSTextField* metaLabel;
@property (nonatomic, retain) HNUnreadButton* unreadButton;
@property (nonatomic, retain) NSButton* gearButton;
@property (nonatomic, retain) NSMenu* contextMenu;
@property (nonatomic, retain) NSMenuItem* markAsReadMenuItem;
@property (nonatomic, retain) NSMenuItem* markAsUnreadMenuItem;

- (void)setTopic:(NSDictionary*)aTopic;
- (void)setNumber:(NSUInteger)aNumber;

@end