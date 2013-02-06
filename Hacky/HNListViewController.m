//
//  HNListView.m
//  Hacky
//
//  Created by Elias Klughammer on 16.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNListViewController.h"

#pragma mark Constants

#define LISTVIEW_CELL_IDENTIFIER  @"MyListViewCell"


@implementation HNListViewController

@synthesize selectedIndex;
@synthesize scrollIndex;
@synthesize topics;
@synthesize listView;
@synthesize applicationIsActive;

- (void)awakeFromNib
{
  selectedIndex = 0;
  
  self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  topics = [[NSMutableArray alloc] init];
  
  listView.delegate = self;
  listView.borderType = NSNoBorder;
  listView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadStories:) name:@"didLoadStories" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldSelectRow:) name:@"shouldSelectRow" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseRightClick:) name:@"didUseRightClick" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickOpenURLMenuButton) name:@"didClickOpenURLMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCommentsMenuButton) name:@"didClickCommentsMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCopyMenuButton) name:@"didClickCopyMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCopyURLMenuButton) name:@"didClickCopyURLMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickInstapaperMenuButton) name:@"didClickInstapaperMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickTweetMenuButton) name:@"didClickTweetMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMarkAsReadMenuButton) name:@"didClickMarkAsReadMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMarkAsUnreadMenuButton) name:@"didClickMarkAsUnreadMenuButton" object:nil];
}

- (void)didLoadStories:(NSNotification*)aNotification
{
  if ([[aNotification object] isKindOfClass:[NSError class]])
    return;
  
  NSString* response = [aNotification object];
  HNParser* parser = [[HNParser alloc] init];
  topics = [parser parseStories:response];
  
  [self setReadMarks];
  
  [listView reloadData];
  
  if (!applicationIsActive)
    [listView scrollRowToVisible:scrollIndex];
  
  [listView setSelectedRow:selectedIndex];
  
  [[listView window] makeFirstResponder:listView];
  
  [self updateBadge];
}

- (void)setReadMarks
{
  scrollIndex = -1;
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = [topics objectAtIndex:i];
    
    if ([defaults valueForKey:[topic valueForKey:@"id"]]) {
      [topic setValue:[NSNumber numberWithInt:1] forKey:@"isRead"];
    }
    else {
      if (scrollIndex == -1) {
        scrollIndex = i;
      }
    }
  }
}

- (void)markAllAsRead
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = [topics objectAtIndex:i];
    [defaults setValue:[NSNumber numberWithInt:1] forKey:[topic valueForKey:@"id"]];
  }
  
  [defaults synchronize];
  [self setReadMarks];
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickOpenURLMenuButton
{
  [self openURL];
}

- (void)openURL {
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSURL* url = [NSURL URLWithString:[topic valueForKey:@"url"]];
  [[NSWorkspace sharedWorkspace] openURL:url];
  
  [topic setValue:[NSNumber numberWithInt:1] forKey:@"isRead"];
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSNumber numberWithInt:1] forKey:[topic valueForKey:@"id"]];
  [defaults synchronize];
  
  [self shouldReloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickCommentsMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSString* baseUrl = @"http://news.ycombinator.com/item?id=";
  NSString* commentsUrl = [baseUrl stringByAppendingString:[topic valueForKey:@"id"]];
  NSURL* url = [NSURL URLWithString:commentsUrl];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickCopyMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSString* stringToCopy = [[[topic valueForKey:@"title"] stringByAppendingString:@" "] stringByAppendingString:[topic valueForKey:@"url"]];
  [self writeToPasteBoard:stringToCopy];
}

- (void)didClickCopyURLMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSString* stringToCopy = [topic valueForKey:@"url"];
  [self writeToPasteBoard:stringToCopy];
}

- (void)didClickInstapaperMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSString* baseURL = @"http://www.instapaper.com/hello2?url=";
  NSString* topicURL = [[topic valueForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* title = [[topic valueForKey:@"title"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* ipURL = [NSString stringWithFormat:@"%@%@&title=%@", baseURL, topicURL, title];
  
  NSURL* url = [NSURL URLWithString:ipURL];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickTweetMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSString* baseURL = @"https://twitter.com/share?url=";
  NSString* topicURL = [[topic valueForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* title = [[topic valueForKey:@"title"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* twitterURL = [NSString stringWithFormat:@"%@%@&title=%@", baseURL, topicURL, title];
  
  NSURL* url = [NSURL URLWithString:twitterURL];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickMarkAsReadMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:[NSNumber numberWithInt:1] forKey:[topic valueForKey:@"id"]];
  [defaults synchronize];
  [topic setValue:[NSNumber numberWithInt:1] forKey:@"isRead"];
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickMarkAsUnreadMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:[topic valueForKey:@"id"]];
  [defaults synchronize];
  [topic removeObjectForKey:@"isRead"];
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (BOOL)writeToPasteBoard:(NSString*)stringToWrite
{
  NSPasteboard* pasteBoard = [NSPasteboard generalPasteboard];
  [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
  return [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

- (void)shouldSelectRow:(NSNotification*)aNotification
{
  NSNumber* row = [aNotification object];
  [listView setSelectedRow:[row intValue]];
}

- (void)updateBadge
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  int unreadTopics = 0;
  
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = topics[i];
    
    if (![defaults valueForKey:[topic valueForKey:@"id"]])
      unreadTopics++;
  }
  
  NSString* badgeString;
  
  if (unreadTopics == 0)
    badgeString = @"";
  else
    badgeString = [NSString stringWithFormat:@"%d", unreadTopics];
  
  NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
  [tile setBadgeLabel:badgeString];
  
  NSNumber* badgeNumber = [NSNumber numberWithInt:unreadTopics];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSetTitleBadge" object:badgeNumber];
}

////////////////////////////////////////////////////////////////////////
// List View Delegates
////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfRowsInListView:(PXListView*)listView {
  return [topics count];
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
  selectedIndex = listView.selectedRow;
  
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  
  id appDelegate = [[NSApplication sharedApplication] delegate];
  
  NSMenuItem* markAsReadMenuItem = [appDelegate markAsReadMenuItem];
  NSMenuItem* markAsUnreadMenuItem = [appDelegate markAsUnreadMenuItem];
  
  markAsReadMenuItem.hidden = !![topic valueForKey:@"isRead"];
  markAsUnreadMenuItem.hidden = ![topic valueForKey:@"isRead"];
}

- (void)didUseRightClick:(NSNotification*)aNotification
{
  NSMutableDictionary* clickedTopic = [aNotification object];
  
  for (int i = 0; i < [topics count]; i++) {
    NSMutableDictionary* topic = topics[i];
    
    if ([[topic valueForKey:@"id"] isEqualToString:[clickedTopic valueForKey:@"id"]]) {
      [listView setSelectedRow:i];
      break;
    }
  }
}

- (HNPostCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row
{
  HNPostCell* cell = [aListView dequeueCellWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
  
  if(!cell) {
    cell = [[HNPostCell alloc] initWithReusableIdentifier:LISTVIEW_CELL_IDENTIFIER];
  }
  
  // --- Set up the new cell:
  [cell setNumber:row + 1];
  [cell setTopic:[topics objectAtIndex:row]];
  
  return cell;
}

- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row
{
  return 51;
}

- (void)listView:(PXListView*)aListView rowDoubleClicked:(NSUInteger)row
{
  [self didClickOpenURLMenuButton];
}

- (void)shouldReloadData
{
  NSTimer* loadTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(reloadData) userInfo:nil repeats:NO];
  [[NSRunLoop currentRunLoop] addTimer:loadTimer forMode:NSRunLoopCommonModes];
}

- (void)reloadData
{
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
}

- (void)keyDown:(NSEvent *)theEvent inListView:(PXListView*)theListView
{
  int keyCode = [theEvent keyCode];
  NSLog(@"%d", keyCode);
  
  // --- return Key
  if (keyCode == 36) {
    [self openURL];
  }
  // --- W / K Key
  else if (keyCode == 13 || keyCode == 40) {
    [listView moveUp:self];
  }
  // --- S / J Key
  else if (keyCode == 1 || keyCode == 38) {
    [listView moveDown:self];
  }
}

@end
