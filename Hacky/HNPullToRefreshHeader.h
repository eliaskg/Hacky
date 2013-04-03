//
//  HNPullToRefreshHeader.h
//  Hacky
//
//  Created by Elias Klughammer on 07.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HNConstants.h"

@interface HNPullToRefreshHeader : NSView
{
  float progress;
  NSImageView* loadingContainer;
  NSImageView* refreshBarLeftImage;
  NSImageView* refreshBarMiddleImage;
  NSImageView* refreshBarRightImage;
  NSTextField* updatedLabel;
  NSMutableArray* loadingImages;
  NSImageView* animationImage;
  NSTimer* animationTimer;
  int animationStep;
}

@property (nonatomic, readwrite) float progress;
@property (nonatomic, retain) NSImageView* loadingContainer;
@property (nonatomic, retain) NSImageView* refreshBarLeftImage;
@property (nonatomic, retain) NSImageView* refreshBarMiddleImage;
@property (nonatomic, retain) NSImageView* refreshBarRightImage;
@property (nonatomic, retain) NSTextField* updatedLabel;
@property (nonatomic, retain) NSMutableArray* loadingImages;
@property (nonatomic, retain) NSImageView* animationImage;
@property (nonatomic, retain) NSTimer* animationTimer;
@property (readwrite) int animationStep;

- (void)setProgress:(float)progress;
- (void)startLoading;
- (void)stopLoading;

@end
