//
//  HNGeneralPreferencesViewController.h
//  Hacky
//
//  Created by Elias Klughammer on 12.10.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface HNGeneralPreferencesViewController : NSViewController <MASPreferencesViewController>
{
  IBOutlet NSButton* unreadCountButton;
  IBOutlet NSPopUpButton* loadingIntervalPopUp;
  IBOutlet NSMatrix* markAsReadMatrix;
}

@property (nonatomic, retain) IBOutlet NSButton* unreadCountButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton* loadingIntervalPopUp;
@property (nonatomic, retain) IBOutlet NSMatrix* markAsReadMatrix;

- (IBAction)didClickUnreadCountButton:(id)sender;
- (IBAction)didChangeLoadingIntervalPopUp:(id)sender;
- (IBAction)didChangeMarkAsReadMatrix:(id)sender;

@end
