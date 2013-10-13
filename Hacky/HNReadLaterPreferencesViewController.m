//
//  HNReadLaterPreferencesViewController.m
//  Hacky
//
//  Created by Elias Klughammer on 13.10.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNReadLaterPreferencesViewController.h"

@interface HNReadLaterPreferencesViewController ()

@end

@implementation HNReadLaterPreferencesViewController

@synthesize service;

@synthesize readLaterServicePopUp;
@synthesize logoutButton;

@synthesize loginPanel;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize cancelButton;
//@synthesize spinner;
@synthesize networkOperation;

- (id)init
{
  return [super initWithNibName:@"HNReadLaterPreferencesViewController" bundle:nil];
}

- (void)awakeFromNib
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  NSString* readLaterService = [defaults valueForKey:@"readLaterService"];
  
  if ([readLaterService isEqualToString:@"Instapaper"])
    [readLaterServicePopUp selectItemAtIndex:1];
  else if ([readLaterService isEqualToString:@"Pocket"]) {
    [readLaterServicePopUp selectItemAtIndex:2];
    [logoutButton setHidden:NO];
  }
  else if ([readLaterService isEqualToString:@"Readability"])
    [readLaterServicePopUp selectItemAtIndex:3];
  else
    [readLaterServicePopUp selectItemAtIndex:0];
  
  // --- Set up the login panel
  [loginButton setKeyEquivalent:@"\r"];
}

- (IBAction)didChangeReadLaterPopUp:(id)sender
{
  service = nil;
  
  NSString* readLaterService;
  
  if ([readLaterServicePopUp indexOfSelectedItem] > 0)
    readLaterService = [[readLaterServicePopUp selectedItem] title];
  else
    readLaterService = nil;
  
  [usernameTextField setStringValue:@""];
  [passwordTextField setStringValue:@""];
  [usernameTextField setEnabled:YES];
  [passwordTextField setEnabled:YES];
  [loginButton setEnabled:YES];
  
  if ([readLaterService isEqualToString:@"Pocket"]) {
    [logoutButton setHidden:NO];
  }
  else {
    [logoutButton setHidden:YES];
  }
  
//  if ([readLaterService isEqualToString:@"Readability"]) {
//    service = readLaterService;
//    
//    [NSApp beginSheet:loginPanel
//       modalForWindow:[[self view] window]
//        modalDelegate:self
//       didEndSelector:nil
//          contextInfo:nil];
//  }
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:readLaterService forKey:@"readLaterService"];
  [defaults synchronize];
}

- (IBAction)didClickLogoutButton:(id)sender
{
  [[PocketAPI sharedAPI] logout];
  [readLaterServicePopUp selectItemAtIndex:0];
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:nil forKey:@"readLaterService"];
  [defaults synchronize];
  
  [logoutButton setHidden:YES];
}

- (IBAction)didClickCancelButton:(id)sender
{
  [spinner setHidden:YES];
  [spinner stopAnimation:self];
  
  [NSApp endSheet:loginPanel];
  [loginPanel orderOut:sender];
}

- (IBAction)didClickLoginButton:(id)sender
{
  NSString* username = [usernameTextField stringValue];
  NSString* password = [passwordTextField stringValue];
  
  [usernameTextField setEnabled:NO];
  [passwordTextField setEnabled:NO];
  [loginButton setEnabled:NO];
  
  [spinner setHidden:NO];
  [spinner startAnimation:self];
  
  if ([service isEqualToString:@"Readability"]) {
    // --- TODO: Validation
    
    NSString* route = [NSString stringWithFormat:@"https://www.readability.com/api/rest/v1/oauth/access_token/"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:route]];
    [request setHTTPMethod:@"POST"];
    
    //set headers
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"Hacky" forHTTPHeaderField: @"User-Agent"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"x_auth_username=%@&x_auth_password=%@&x_auth_mode=client_auth&oauth_consumer_key=%@", username, password, READABILITY_API_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", [NSString stringWithFormat:@"x_auth_username=%@&x_auth_password=%@&x_auth_mode=client_auth&oauth_consumer_key=%@", username, password, READABILITY_API_KEY]);
    
    //post
    [request setHTTPBody:postBody];
    
    networkOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __block HNReadLaterPreferencesViewController* myself = self;
    
    [networkOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"ok");
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"%@", error);
      [usernameTextField setEnabled:YES];
      [passwordTextField setEnabled:YES];
      [loginButton setEnabled:YES];
      
      [spinner setHidden:YES];
      [spinner stopAnimation:self];
    }];
    
    [networkOperation start];
  }
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
  return @"ReadLaterPreferences";
}

- (NSImage *)toolbarItemImage
{
  return [NSImage imageNamed:@"preferencesReadLater"];
}

- (NSString *)toolbarItemLabel
{
  return @"Read Later";
}

@end
