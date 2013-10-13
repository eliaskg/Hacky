//
//  HNReadLaterPreferencesViewController.h
//  Hacky
//
//  Created by Elias Klughammer on 13.10.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "PocketAPI.h"
#import "HNConfig.h"
#import "AFNetworking.h"

@interface HNReadLaterPreferencesViewController : NSViewController <MASPreferencesViewController>
{
  NSString* service;
  
  IBOutlet NSPopUpButton* readLaterServicePopUp;
  IBOutlet NSButton* logoutButton;
  
  IBOutlet NSPanel* loginPanel;
  IBOutlet NSTextField* usernameTextField;
  IBOutlet NSTextField* passwordTextField;
  IBOutlet NSButton* loginButton;
  IBOutlet NSButton* cancelButton;
  IBOutlet NSProgressIndicator* spinner;
  AFHTTPRequestOperation* networkOperation;
}

@property (nonatomic, retain) NSString* service;

@property (nonatomic, retain) IBOutlet NSPopUpButton* readLaterServicePopUp;
@property (nonatomic, retain) IBOutlet NSButton* logoutButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator* logoutSpinner;

@property (nonatomic, retain) IBOutlet NSPanel* loginPanel;
@property (nonatomic, retain) IBOutlet NSTextField* usernameTextField;
@property (nonatomic, retain) IBOutlet NSTextField* passwordTextField;
@property (nonatomic, retain) IBOutlet NSButton* loginButton;
@property (nonatomic, retain) IBOutlet NSButton* cancelButton;
@property (nonatomic, retain) AFHTTPRequestOperation* networkOperation;

- (IBAction)didChangeReadLaterPopUp:(id)sender;
- (IBAction)didClickLogoutButton:(id)sender;

- (IBAction)didClickCancelButton:(id)sender;
- (IBAction)didClickLoginButton:(id)sender;

@end
