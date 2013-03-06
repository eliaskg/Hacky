//
//  HNListViewController.m
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
@synthesize category;
@synthesize topics;
@synthesize listView;
@synthesize applicationIsActive;
@synthesize isLoading;
@synthesize spinner;

- (void)awakeFromNib
{
  selectedIndex = 0;
  
  self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  topics = [[NSMutableArray alloc] init];
  
  listView.delegate = self;
  listView.borderType = NSNoBorder;
  listView.autoresizingMask = self.view.autoresizingMask;
  listView.refreshBlock = ^(EQSTRScrollView *scrollView) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldLoadStories" object:nil];
  };
  
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

- (void)setIsLoading:(BOOL)loading
{
  if (loading == isLoading)
    return;
  
  isLoading = loading;
  
  if (isLoading) {
    if (!spinner) {
      spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.view.bounds.size.width / 2 - 18 / 2, self.view.bounds.size.height / 2 - 18 / 2, 18, 18)];
      spinner.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
      [spinner setStyle:NSProgressIndicatorSpinningStyle];
      spinner.hidden = YES;
      [self.view addSubview:spinner];
    }
    
    [spinner startAnimation:self];
  }
  else {
    [spinner stopAnimation:self];
  }
  
  spinner.hidden = !isLoading;
  listView.hidden = isLoading;
}

- (void)didLoadStories:(NSNotification*)aNotification
{
  [self setIsLoading:NO];
  
  if ([[aNotification object] isKindOfClass:[NSError class]])
    return;
  
  NSString* response = [aNotification object];
  HNParser* parser = [[HNParser alloc] init];
  topics = [parser parseStories:response];
  
  [listView stopLoading];
  
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
  
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = [topics objectAtIndex:i];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", [topic valueForKey:@"id"], [NSNumber numberWithInt:1]];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    if ([results count] > 0) {
      [topic setValue:[NSNumber numberWithInt:1] forKey:@"isRead"];
    }
    else {
      if (scrollIndex == -1) {
        scrollIndex = i;
      }
    }
  }
}

- (void)setTopicIsRead:(NSMutableDictionary*)theTopic
{
  if ([theTopic valueForKey:@"isRead"] == [NSNumber numberWithInt:1])
    return;
  
  NSString* topicId = [theTopic valueForKey:@"id"];
  
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSManagedObject *cdTopic = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
  [cdTopic setValue:topicId forKey:@"id"];
  [cdTopic setValue:[NSNumber numberWithBool:YES] forKey:@"isRead"];
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (void)setTopicIsUnread:(NSMutableDictionary*)theTopic
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", [theTopic valueForKey:@"id"], [NSNumber numberWithInt:1]];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  for (NSManagedObject *managedObject in results) {
    [context deleteObject:managedObject];
  }
  
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (BOOL)topicIsRead:(NSMutableDictionary*)theTopic
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", [theTopic valueForKey:@"id"], [NSNumber numberWithInt:1]];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  return [results count] > 0;
}

- (void)markAllAsRead
{
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = [topics objectAtIndex:i];
    [self setTopicIsRead:topic];
  }
  
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
  
  [self setTopicIsRead:topic];
  
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
  NSString* twitterURL = [NSString stringWithFormat:@"%@%@&text=%@", baseURL, topicURL, title];
  
  NSURL* url = [NSURL URLWithString:twitterURL];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickMarkAsReadMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  
  [self setTopicIsRead:topic];

  [topic setValue:[NSNumber numberWithInt:1] forKey:@"isRead"];
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickMarkAsUnreadMenuButton
{
  NSMutableDictionary* topic = [topics objectAtIndex:selectedIndex];
  
  [self setTopicIsUnread:topic];
  
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
  int unreadTopics = 0;
  
  for (int i = 0; i < [topics count]; i++)
  {
    NSMutableDictionary* topic = topics[i];
    
    if (![self topicIsRead:topic])
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
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStory" object:topic];
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
  
  if ([category isEqualToString:@"Top"])
    [cell setNumber:row + 1.0];
  else
    [cell setNumber:nil];
  
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
