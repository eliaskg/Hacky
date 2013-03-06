//
//  HNCommentsViewController.h
//  Hacky
//
//  Created by Elias Klughammer on 15.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "HNParser.h"
#import "HNStory.h"
#import "HNConnectionController.h"

@interface HNCommentsViewController : NSViewController
{
  WebView* webView;
  HNStory* story;
  HNConnectionController* connectionController;
  NSProgressIndicator* spinner;
  BOOL isLoading;
}

@property (nonatomic, retain) WebView* webView;
@property (nonatomic, retain) HNStory* story;
@property (nonatomic, retain) HNConnectionController* connectionController;
@property (nonatomic, retain) NSProgressIndicator* spinner;
@property (nonatomic, assign) BOOL isLoading;

@end
