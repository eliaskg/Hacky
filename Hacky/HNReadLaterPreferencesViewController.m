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

- (id)init
{
  return [super initWithNibName:@"HNReadLaterPreferencesViewController" bundle:nil];
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
