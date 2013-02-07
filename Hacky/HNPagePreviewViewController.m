//
//  HNPagePreviewViewController.m
//  Hacky
//
//  Created by Alex Rozanski on 07/02/2013.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNPagePreviewViewController.h"

@implementation HNPagePreviewViewController

- (void)awakeFromNib
{
  NSURL* appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:[NSURL URLWithString:@"http://apple.com"]];
  if (appURL) {
    CFStringRef appNameRef;
    LSCopyDisplayNameForURL((__bridge_retained CFURLRef)appURL, &appNameRef);
    
    self.openInButton.title = [NSString stringWithFormat:@"Open in %@...", (__bridge_transfer NSString*)appNameRef];
  }
}

- (void)setPageURL:(NSURL *)newURL
{
  _pageURL = newURL;
  
  NSURLRequest* request = nil;
  if (_pageURL) {
    request = [NSURLRequest requestWithURL:self.previewURL];
  }
  
  // Reset the web view to a blank page.
  [self.webView setMainFrameURL:@""];
  
  if (request)
    [self.webView.mainFrame loadRequest:request];
}

- (NSURL*)previewURL
{
  NSString* urlString = [[self.pageURL absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString* readabilityURL = [NSString stringWithFormat:@"http://www.readability.com/m?url=%@", urlString];
  
  return [NSURL URLWithString:readabilityURL];
}

#pragma mark - Actions

- (IBAction)openInAction:(id)sender
{
  if (!self.pageURL)
    return;
  
  [[NSWorkspace sharedWorkspace] openURL:self.pageURL];
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
  [self.loadingIndicator startAnimation:self];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
  [self.loadingIndicator stopAnimation:self];
}

@end
