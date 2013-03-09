//
//  HNCommentsViewController.m
//  Hacky
//
//  Created by Elias Klughammer on 15.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNCommentsViewController.h"

@implementation HNCommentsViewController

@synthesize webView;
@synthesize story;
@synthesize connectionController;
@synthesize loadingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    webView = [[WebView alloc] initWithFrame:self.view.bounds];
    webView.policyDelegate = self;
    webView.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:webView];
    
    loadingView = [[HNLoadingView alloc] init];
    loadingView.frame = webView.frame;
    [self.view addSubview:loadingView];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"comments"
                                                         ofType:@"html"
                                                    inDirectory:@"WebViews"];

    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
    [[webView mainFrame] loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectCategory:) name:@"didSelectCategory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStory:) name:@"didSelectStory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadComments:) name:@"didLoadComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldClearComments) name:@"shouldClearComments" object:nil];
  }
    
  return self;
}

- (void)didSelectCategory:(NSNotification*)aNotification
{
  [self shouldClearComments];
}

- (void)didSelectStory:(NSNotification*)aNotification
{ 
  HNStory* theStory = [aNotification object];
  
  if ([story.storyId isEqualToString:theStory.storyId])
    return;
  
  if (connectionController)
    [connectionController cancel];
  
  loadingView.isLoading = YES;
  
  story = theStory;
  
  NSDictionary* params = [NSDictionary dictionaryWithObject:story.storyId forKey:@"id"];
  
  connectionController = [HNConnectionController connectionWithIdentifier:@"comments" params:params];
}

- (void)didLoadComments:(NSNotification*)aNotification
{
  if ([[aNotification object] isKindOfClass:[NSError class]])
    return;
  
  NSString* response = [aNotification object];
  
  HNParser* parser = [[HNParser alloc] init];
  NSMutableArray* comments = [parser parseComments:response];
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:comments
                                                     options:nil
                                                       error:&error];
  
  if (!jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* jsonStringCleaned1 = [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    NSString* jsonStringCleaned2 = [jsonStringCleaned1 stringByReplacingOccurrencesOfString:@"\\t" withString:@"  "];
    NSString* jsonStringCleaned3 = [jsonStringCleaned2 stringByReplacingOccurrencesOfString:@"\\ " withString:@""];
    NSString* jsonStringCleaned4 = [jsonStringCleaned3 stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    NSString* jsonStringCleaned5 = [jsonStringCleaned4 stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString* jsFunction = [NSString stringWithFormat:@"parseComments('%@')", jsonStringCleaned5];

    [webView stringByEvaluatingJavaScriptFromString:jsFunction];
  }
  
  loadingView.isLoading = NO;
}

- (void)shouldClearComments
{
  [webView stringByEvaluatingJavaScriptFromString:@"clearComments()"];
}

- (void)webView:(WebView *)webView
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id <WebPolicyDecisionListener>)listener
{
  if ([actionInformation objectForKey:WebActionElementKey]) {
    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
  }
  else {
    [listener use];
  }
}

@end
