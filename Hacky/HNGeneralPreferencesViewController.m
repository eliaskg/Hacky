//
//  HNGeneralPreferencesViewController.m
//  Hacky
//
//  Created by Elias Klughammer on 12.10.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNGeneralPreferencesViewController.h"

@interface HNGeneralPreferencesViewController ()

@end

@implementation HNGeneralPreferencesViewController

@synthesize unreadCountButton;
@synthesize loadingIntervalPopUp;
@synthesize markAsReadMatrix;

- (id)init
{
  return [super initWithNibName:@"HNGeneralPreferencesViewController" bundle:nil];
}

- (void)awakeFromNib
{
  // --- Prepare UI
  NSArray* menuItems = [NSArray arrayWithObjects:@"Every 5 minutes", @"Every 15 minutes", @"Every 30 minutes", @"Every hour", @"Manually", nil];

  [loadingIntervalPopUp removeAllItems];
  [loadingIntervalPopUp addItemsWithTitles:menuItems];
  
  // --- Load user defaults
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSInteger loadingInterval = [defaults integerForKey:@"loadingInterval"];
  BOOL shouldShowUnreadCountInIcon = [defaults boolForKey:@"shouldShowUnreadCountInIcon"];
  NSString* markAsReadIf = [defaults valueForKey:@"markAsReadIf"];
  
  if (loadingInterval == 5 * 60)
    [loadingIntervalPopUp selectItemAtIndex:0];
  else if (loadingInterval == 15 * 60)
    [loadingIntervalPopUp selectItemAtIndex:1];
  else if (loadingInterval == 30 * 60)
    [loadingIntervalPopUp selectItemAtIndex:2];
  else if (loadingInterval == 60 * 60)
    [loadingIntervalPopUp selectItemAtIndex:3];
  else
    [loadingIntervalPopUp selectItemAtIndex:4];
  
  unreadCountButton.state = shouldShowUnreadCountInIcon ? NSOnState : NSOffState;
  
  if ([markAsReadIf isEqualToString:@"link"])
    [markAsReadMatrix selectCellAtRow:0 column:0];
  else
    [markAsReadMatrix selectCellAtRow:1 column:0];
}

- (IBAction)didChangeLoadingIntervalPopUp:(id)sender
{
  NSInteger index = [loadingIntervalPopUp indexOfSelectedItem];
  NSInteger interval;
  
  if (index == 0)
    interval = 5 * 60;
  else if (index == 1)
    interval = 15 * 60;
  else if (index == 2)
    interval = 30 * 60;
  else if (index == 3)
    interval = 60 * 60;
  else
    interval = -1;
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setInteger:interval forKey:@"loadingInterval"];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldResetLoadingInterval" object:nil];
}

- (IBAction)didClickUnreadCountButton:(id)sender
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if ([unreadCountButton state] == NSOnState)
    [defaults setBool:YES forKey:@"shouldShowUnreadCountInIcon"];
  else
    [defaults setBool:NO forKey:@"shouldShowUnreadCountInIcon"];
  
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateBadge" object:nil];
}

- (IBAction)didChangeMarkAsReadMatrix:(id)sender
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if ([markAsReadMatrix selectedTag] == 1)
    [defaults setValue:@"link" forKey:@"markAsReadIf"];
  else
    [defaults setValue:@"comments" forKey:@"markAsReadIf"];
  
  [defaults synchronize];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
  return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
  return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
  return @"General";
}

@end
