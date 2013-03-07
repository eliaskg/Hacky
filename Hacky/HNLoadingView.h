//
//  HNLoadingView.h
//  Hacky
//
//  Created by Elias Klughammer on 07.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HNLoadingView : NSView
{
  BOOL isLoading;
  NSProgressIndicator* spinner;
}

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) NSProgressIndicator* spinner;

@end
