//
//  HNPagePreviewViewController.h
//  Hacky
//
//  Created by Alex Rozanski on 07/02/2013.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>

@interface HNPagePreviewViewController : NSViewController

@property (nonatomic, strong) IBOutlet WebView *webView;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *loadingIndicator;
@property (nonatomic, strong) IBOutlet NSButton *openInButton;
@property (nonatomic, strong) NSURL *pageURL;

- (IBAction)openInAction:(id)sender;

@end
