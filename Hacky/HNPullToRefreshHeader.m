//
//  HNPullToRefreshHeader.m
//  Hacky
//
//  Created by Elias Klughammer on 07.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNPullToRefreshHeader.h"

@implementation HNPullToRefreshHeader

@synthesize progress;
@synthesize loadingContainer;
@synthesize refreshBarLeftImage;
@synthesize refreshBarMiddleImage;
@synthesize refreshBarRightImage;
@synthesize updatedLabel;
@synthesize loadingImages;
@synthesize animationImage;
@synthesize animationTimer;
@synthesize animationStep;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      animationStep = 1;
      
      self.autoresizingMask = NSViewWidthSizable;
      
      loadingContainer = [[NSImageView alloc] initWithFrame:NSMakeRect(HN_LEFT_MARGIN + 1, 11, 52, 11)];
      loadingContainer.image = [NSImage imageNamed:@"refreshContainer"];
      [self addSubview:loadingContainer];
      
      refreshBarLeftImage = [[NSImageView alloc] initWithFrame:NSMakeRect(HN_LEFT_MARGIN + 1, 11, 5, 11)];
      refreshBarLeftImage.image = [NSImage imageNamed:@"refreshBarLeft"];
      [self addSubview:refreshBarLeftImage];
      
      refreshBarMiddleImage = [[NSImageView alloc] initWithFrame:NSMakeRect(HN_LEFT_MARGIN + 1 + 5, 11, 1, 11)];
      refreshBarMiddleImage.imageScaling = NSScaleNone;
      refreshBarMiddleImage.image = [NSImage imageNamed:@"refreshBarMiddle"];
      [self addSubview:refreshBarMiddleImage];
      
      refreshBarRightImage = [[NSImageView alloc] initWithFrame:NSMakeRect(HN_LEFT_MARGIN + 1 + 5 + 1, 11, 5, 11)];
      refreshBarRightImage.image = [NSImage imageNamed:@"refreshBarRight"];
      [self addSubview:refreshBarRightImage];
      
      updatedLabel = [[NSTextField alloc] initWithFrame:CGRectMake(HN_LEFT_MARGIN + 60, 9, 200, 80)];
      updatedLabel.font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10];
      [updatedLabel setTextColor:HN_GRAY];
      [updatedLabel setEditable:NO];
      [updatedLabel setBezeled:NO];
      [updatedLabel setBordered:NO];
      [self addSubview:updatedLabel];
      
      animationImage = [[NSImageView alloc] initWithFrame:loadingContainer.frame];
      animationImage.hidden = YES;
      [self addSubview:animationImage];
      
      [self initLoadingImages];
    }
    
    return self;
}

- (void)initLoadingImages
{
  loadingImages = [[NSMutableArray alloc] init];
  
  for (int i = 1; i <= 15; i++) {
    NSString* imageName = [NSString stringWithFormat:@"refreshBar%d", i];
    NSImage* loadingImage = [NSImage imageNamed:imageName];
    
    if (loadingImage)
      [loadingImages addObject:loadingImage];
  }
}

- (void)drawRect:(NSRect)aRect
{
  aRect = [self bounds];
  
  [HN_GRAY_LIGHTER set];
  
  // Draw divider
  NSBezierPath *divider = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, aRect.size.width, 1)];
  [divider fill];
}

- (void)setProgress:(float)newProgress
{
  if (newProgress == progress)
    return;
  
  progress = newProgress;
  
  [refreshBarMiddleImage setFrameSize:NSMakeSize(progress * 42, refreshBarMiddleImage.bounds.size.height)];
  [refreshBarRightImage setFrameOrigin:NSMakePoint(loadingContainer.frame.origin.x + progress * 47, refreshBarRightImage.frame.origin.y)];
}

- (void)startLoading
{  
  animationTimer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(animationTimerDidFire) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
  
  animationImage.hidden = NO;
  
  [updatedLabel setStringValue:@"Loading"];
  [updatedLabel sizeToFit];
}

- (void)stopLoading
{  
  animationImage.hidden = YES;
  animationImage.image = nil;
  [animationTimer invalidate];
  animationStep = 1;
}

- (void)updateLabelWithDate:(NSDate *)date
{
  NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc] init];
  [timeDateFormatter setLocale: [NSLocale autoupdatingCurrentLocale]];
  [timeDateFormatter setDateFormat:@"HH:mm"];
  NSString *timeDateString = [timeDateFormatter stringFromDate:date];
  
  NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
  [dayDateFormatter setTimeStyle:NSDateFormatterNoStyle];
  [dayDateFormatter setDateStyle:NSDateFormatterMediumStyle];
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"];
  [dayDateFormatter setLocale:locale];
  [dayDateFormatter setDoesRelativeDateFormatting:YES];
  NSString *dayDateString = [dayDateFormatter stringFromDate:date];
  
  NSString *updatedString = [NSString stringWithFormat:@"Updated %@ at %@", dayDateString, timeDateString];
  [updatedLabel setStringValue:updatedString];
  [updatedLabel sizeToFit];
}

- (void)animationTimerDidFire
{
  
  if (animationStep == [loadingImages count])
    animationStep = 1;
  else
    animationStep++;
  
  animationImage.image = [loadingImages objectAtIndex:animationStep-1];
}


@end
