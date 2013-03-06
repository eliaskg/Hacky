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
@synthesize stories;
@synthesize listView;
@synthesize applicationIsActive;
@synthesize isLoading;
@synthesize spinner;

- (void)awakeFromNib
{
  selectedIndex = 0;
  
  self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  stories = [[NSMutableArray alloc] init];
  
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
  stories = [parser parseStories:response];
  
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
  
  for (int i = 0; i < [stories count]; i++)
  {
    HNStory* story = [stories objectAtIndex:i];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", story.storyId, [NSNumber numberWithInt:1]];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    if ([results count] > 0) {
      story.isRead = YES;
    }
    else {
      if (scrollIndex == -1) {
        scrollIndex = i;
      }
    }
  }
}

- (void)setStoryIsRead:(HNStory*)theStory
{
  if (theStory.isRead)
    return;
  
  NSString* storyId = theStory.storyId;
  
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSManagedObject *cdStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
  [cdStory setValue:storyId forKey:@"id"];
  [cdStory setValue:[NSNumber numberWithBool:YES] forKey:@"isRead"];
  NSError *error;
  if(![context save:&error]){
    NSLog(@"%@", error);
  }
}

- (void)setStoryIsUnread:(HNStory*)theStory
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", theStory.storyId, [NSNumber numberWithInt:1]];
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

- (BOOL)storyIsRead:(HNStory*)theStory
{
  NSManagedObjectContext* context = [[HNAppDelegate sharedAppDelegate] managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@ AND isRead == %@", theStory.storyId, [NSNumber numberWithInt:1]];
  [request setEntity:entity];
  [request setPredicate:predicate];
  NSMutableArray *results = [[context executeFetchRequest:request error:nil] mutableCopy];
  
  return [results count] > 0;
}

- (void)markAllAsRead
{
  for (int i = 0; i < [stories count]; i++)
  {
    NSMutableDictionary* story = [stories objectAtIndex:i];
    [self setStoryIsRead:story];
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
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSURL* url = [NSURL URLWithString:story.url];
  [[NSWorkspace sharedWorkspace] openURL:url];
  
  story.isRead = YES;
  
  [self setStoryIsRead:story];
  
  [self shouldReloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickCommentsMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSString* baseUrl = @"http://news.ycombinator.com/item?id=";
  NSString* commentsUrl = [baseUrl stringByAppendingString:story.storyId];
  NSURL* url = [NSURL URLWithString:commentsUrl];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickCopyMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSString* stringToCopy = [[story.title stringByAppendingString:@" "] stringByAppendingString:story.url];
  [self writeToPasteBoard:stringToCopy];
}

- (void)didClickCopyURLMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  [self writeToPasteBoard:story.url];
}

- (void)didClickInstapaperMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSString* baseURL = @"http://www.instapaper.com/hello2?url=";
  NSString* storyURL = [story.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* title = [story.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* ipURL = [NSString stringWithFormat:@"%@%@&title=%@", baseURL, storyURL, title];
  
  NSURL* url = [NSURL URLWithString:ipURL];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickTweetMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSString* baseURL = @"https://twitter.com/share?url=";
  NSString* storyURL = [story.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* title = [story.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString* twitterURL = [NSString stringWithFormat:@"%@%@&text=%@", baseURL, storyURL, title];
  
  NSURL* url = [NSURL URLWithString:twitterURL];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)didClickMarkAsReadMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  [self setStoryIsRead:story];

  story.isRead = YES;
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickMarkAsUnreadMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  [self setStoryIsUnread:story];
  
  story.isRead = NO;
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
  int unreadStories = 0;
  
  for (int i = 0; i < [stories count]; i++)
  {
    NSMutableDictionary* story = stories[i];
    
    if (![self storyIsRead:story])
      unreadStories++;
  }
  
  NSString* badgeString;
  
  if (unreadStories == 0)
    badgeString = @"";
  else
    badgeString = [NSString stringWithFormat:@"%d", unreadStories];
  
  NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
  [tile setBadgeLabel:badgeString];
  
  NSNumber* badgeNumber = [NSNumber numberWithInt:unreadStories];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSetTitleBadge" object:badgeNumber];
}

////////////////////////////////////////////////////////////////////////
// List View Delegates
////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfRowsInListView:(PXListView*)listView {
  return [stories count];
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
  selectedIndex = listView.selectedRow;
  
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  id appDelegate = [[NSApplication sharedApplication] delegate];
  
  NSMenuItem* markAsReadMenuItem = [appDelegate markAsReadMenuItem];
  NSMenuItem* markAsUnreadMenuItem = [appDelegate markAsUnreadMenuItem];
  
  markAsReadMenuItem.hidden = !!story.isRead;
  markAsUnreadMenuItem.hidden = !story.isRead;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStory" object:story];
}

- (void)didUseRightClick:(NSNotification*)aNotification
{
  HNStory* clickedStory = [aNotification object];
  
  for (int i = 0; i < [stories count]; i++) {
    HNStory* story = stories[i];
    
    if ([story.storyId isEqualToString:clickedStory.storyId]) {
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
  
  [cell setStory:[stories objectAtIndex:row]];
  
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
