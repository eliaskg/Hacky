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
  self = [super initWithNibName:@"HNCommentsViewController" bundle:nibBundleOrNil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCopyMenuButton:) name:@"didClickCopyMenuButton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStory:) name:@"didSelectStory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadComments:) name:HNConnectionControllerDidLoadCommentsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldClearComments) name:@"shouldClearComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRaiseConnectionFailure:) name:HNConnectionControllerDidRaiseConnectionFailureNotification object:connectionController];
  }
    
  return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectCategory" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didClickCopyMenuButton" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStory" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HNConnectionControllerDidLoadCommentsNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"shouldClearComments" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HNConnectionControllerDidRaiseConnectionFailureNotification object:connectionController];
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
  
  NSMutableArray* comments = [parser parseComments:response hasURL:story.hasURL];
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:comments
                                                     options:nil
                                                       error:&error];
  
  if (!jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    NSMutableString* jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] mutableCopy];
    
    [jsonString replaceOccurrencesOfString:@"\\\\" withString:@"&#092;" options:nil range:NSMakeRange(0, [jsonString length])];
    [jsonString replaceOccurrencesOfString:@"\\n" withString:@"&#012;" options:nil range:NSMakeRange(0, [jsonString length])];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\\\[^\"\\/t]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    jsonString = [[regex stringByReplacingMatchesInString:jsonString options:0 range:NSMakeRange(0, [jsonString length]) withTemplate:@""] mutableCopy];

    [jsonString replaceOccurrencesOfString:@"\\t" withString:@"  " options:nil range:NSMakeRange(0, [jsonString length])];
    [jsonString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:nil range:NSMakeRange(0, [jsonString length])];
    [jsonString replaceOccurrencesOfString:@"'" withString:@"\\'" options:nil range:NSMakeRange(0, [jsonString length])];
    
    NSString* jsFunction = [NSString stringWithFormat:@"parseComments('%@')", jsonString];
    
//    NSLog(@"%@", jsFunction);

    [webView stringByEvaluatingJavaScriptFromString:jsFunction];
  }
  
  loadingView.isLoading = NO;
}

- (void)didClickCopyMenuButton:(NSNotification*)aNotification
{  
  if (![webView selectedFrame])
    return;
  
  [webView copy:self];
}

- (void)shouldClearComments
{
  [webView stringByEvaluatingJavaScriptFromString:@"clearComments()"];
}

- (void)didRaiseConnectionFailure:(NSNotification*)notification
{
  [self shouldClearComments];
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
