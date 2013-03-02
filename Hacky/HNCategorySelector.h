//
//  HNCategorySelector.h
//  Hacky
//
//  Created by Elias Klughammer on 02.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HNCategorySelector : NSControl
{
  NSString* title;
  NSTextField* titleLabel;
  NSImage* dropDownImageNormal;
  NSImage* dropDownImageActive;
  NSImageView* dropDownImageView;
  NSTrackingArea* trackingArea;
  NSMenu* menu;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSImage* dropDownImageNormal;
@property (nonatomic, retain) NSImage* dropDownImageActive;
@property (nonatomic, retain) NSImageView* dropDownImageView;
@property (nonatomic, retain) NSTrackingArea* trackingArea;
@property (nonatomic, retain) NSMenu* menu;

@end