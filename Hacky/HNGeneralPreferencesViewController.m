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

- (id)init
{
  return [super initWithNibName:@"HNGeneralPreferencesViewController" bundle:nil];
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
  return @"Hallo test";
}

@end
