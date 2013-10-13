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
@synthesize loadingView;
@synthesize failureView;

- (id)init
{
  return [super initWithNibName:@"HNListViewController" bundle:nil];
}

- (void)awakeFromNib
{
  selectedIndex = 0;
  
  self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
  stories = [[NSArray alloc] init];
  
  listView.delegate = self;
  listView.borderType = NSNoBorder;
  listView.autoresizingMask = self.view.autoresizingMask;
  listView.refreshBlock = ^(EQSTRScrollView *scrollView) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldLoadStories" object:nil];
  };
  
  loadingView = [[HNLoadingView alloc] init];
  loadingView.frame = listView.frame;
  [self.view addSubview:loadingView];
  
  failureView = [[HNFailureView alloc] init];
  [self.view addSubview:failureView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDidUpdate:) name:@"iCloudDidUpdate" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadStories:) name:HNConnectionControllerDidLoadStoriesNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadFavorites:) name:HNConnectionControllerDidLoadFavoritesNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldSelectRow:) name:@"shouldSelectRow" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseRightClick:) name:@"didUseRightClick" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadData) name:@"shouldReloadData" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickOpenURLMenuButton) name:@"didClickOpenURLMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCommentsMenuButton) name:@"didClickCommentsMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCopyMenuButton:) name:@"didClickCopyMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCopyURLMenuButton) name:@"didClickCopyURLMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickReadLaterMenuButton) name:@"didClickReadLaterMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickTweetMenuButton) name:@"didClickTweetMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMarkAsReadMenuButton) name:@"didClickMarkAsReadMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMarkAsUnreadMenuButton) name:@"didClickMarkAsUnreadMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMakeFavoriteMenuButton) name:@"didClickMakeFavoriteMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickDeleteFavoriteMenuButton) name:@"didClickDeleteFavoriteMenuButton" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:@"shouldUpdateBadge" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRaiseConnectionFailure:) name:HNConnectionControllerDidRaiseConnectionFailureNotification object:nil];
}

- (void)setCategory:(NSString *)theCategory
{
  if ([category isEqualToString:theCategory])
    return;
  
  category = theCategory;
  
  [listView.refreshHeader setHidden:[category isEqualToString:@"Favorites"]];
  
  selectedIndex = 0;
  
  [failureView hide];
}

- (void)iCloudDidUpdate:(NSNotification*)aNotification
{
  [self setReadMarks];
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  [self updateBadge];
}

- (void)didLoadStories:(NSNotification*)aNotification
{
  if ([[aNotification object] isKindOfClass:[NSError class]])
    return;
  
  NSString* response = [aNotification object];
  HNParser* parser = [[HNParser alloc] init];
  
  NSArray* parsedStories = [parser parseStories:response];
  if (parsedStories == nil) {
	  return;
  }
	
  loadingView.isLoading = NO;
  [failureView hide];
  
  stories = parsedStories;
  
  [listView stopLoading];
  [[listView refreshHeader] updateLabelWithDate:[NSDate date]];
  
  [self setReadMarks];
  
  [listView reloadData];
  
  if (!applicationIsActive)
    [listView scrollRowToVisible:scrollIndex];
  
  [listView setSelectedRow:selectedIndex];
  
  [[listView window] makeFirstResponder:listView];
  
  [self updateBadge];
}

- (void)didLoadFavorites:(NSNotification*)aNotification
{
  NSMutableArray* favorites = [aNotification object];
  
  NSMutableArray *newStories = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < [favorites count]; i++) {
    NSManagedObject* favorite = favorites[i];
    HNStory* story  = [[HNStory alloc] init];
    story.storyId   = [favorite valueForKey:@"id"];
    story.title     = [favorite valueForKey:@"title"];
    story.url       = [favorite valueForKey:@"url"];
    NSDate* createdAt = [favorite valueForKey:@"created_at"];
    NSString* createdAtRelative = [createdAt relativeDate];
    story.createdAt = createdAtRelative;
    story.isFavorite = YES;
    [newStories addObject:story];
  }
  
  stories = newStories;
  
  loadingView.isLoading = NO;
  [listView stopLoading];
  [[listView refreshHeader] updateLabelWithDate:[NSDate date]];
  [listView.refreshHeader setHidden:YES];
  [self reloadData];
  [[listView window] makeFirstResponder:listView];
}

- (void)setReadMarks
{
  scrollIndex = -1;
  
  for (int i = 0; i < [stories count]; i++)
  {
    HNStory* story = [stories objectAtIndex:i];
    
    story.isRead = [story isReadInDB];

    if (!story.isRead) {
      if (scrollIndex == -1) {
        scrollIndex = i;
      }
    }
    
    story.isFavorite = [story isFavoriteInDB];
  }
}

- (void)markAllAsRead
{
  for (int i = 0; i < [stories count]; i++)
  {
    HNStory* story = [stories objectAtIndex:i];
    [story setIsReadInDB];
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
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[defaults valueForKey:@"markAsReadIf"] isEqualToString:@"link"]) {
    story.isRead = YES;
    [story setIsReadInDB];
  }
  
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

- (void)didClickCopyMenuButton:(NSNotification*)aNotification
{
  id responder = [aNotification object];
  
  if (responder != listView)
    return;
  
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSString* stringToCopy = [[story.title stringByAppendingString:@" "] stringByAppendingString:story.url];
  [self writeToPasteBoard:stringToCopy];
}

- (void)didClickCopyURLMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  [self writeToPasteBoard:story.url];
}

- (void)didClickReadLaterMenuButton
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  
  NSString* readLaterService = [defaults valueForKey:@"readLaterService"];
  
  if (!readLaterService) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldOpenPreferences" object:@"ReadLaterPreferences"];
    
    return;
  }
  
  HNStory* story = [stories objectAtIndex:selectedIndex];
  NSURL* url = [NSURL URLWithString:story.url];
  
  if ([readLaterService isEqualToString:@"Pocket"]) {
    [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
      if(error) {
        // there was an issue connecting to Pocket
        // present some UI to notify if necessary
        NSLog(@"%@", error);
      } else {
        // the URL was saved successfully
        [self showReadLaterSuccessNotificationWithService:@"Pocket" URL:story.url];
      }
    }];
  }
  else if ([readLaterService isEqualToString:@"Instapaper"]) {
    NSString* baseURL = @"http://www.instapaper.com/hello2?url=";
    NSString* storyURL = [story.url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString* title = [story.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString* ipURL = [NSString stringWithFormat:@"%@%@&title=%@", baseURL, storyURL, title];
    
    NSURL* url = [NSURL URLWithString:ipURL];
    [[NSWorkspace sharedWorkspace] openURL:url];
  }
  else if ([readLaterService isEqualToString:@"Reading List"]) {
    NSString* appleScript = [NSString stringWithFormat:@"tell application \"Safari\" to add reading list item \"%@\"", story.url];
    
    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:appleScript];
    NSDictionary* error;
    [script executeAndReturnError:&error];
    
    [self showReadLaterSuccessNotificationWithService:@"Reading List" URL:story.url];
  }
}

- (void)showReadLaterSuccessNotificationWithService:(NSString*)service URL:(NSString*)url
{
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = [NSString stringWithFormat:@"Story saved to %@", service];
  notification.informativeText = url;
  notification.soundName = NSUserNotificationDefaultSoundName;
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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
  
  [story setIsReadInDB];

  story.isRead = YES;
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickMarkAsUnreadMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  [story setIsUnreadInDB];
  
  story.isRead = NO;
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickMakeFavoriteMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  [story makeFavoriteInDB];
  
  story.isFavorite = YES;
  [listView reloadData];
  [listView setSelectedRow:selectedIndex];
  
  [self updateBadge];
}

- (void)didClickDeleteFavoriteMenuButton
{
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  [story deleteFavoriteInDB];
  
  if ([category isEqualToString:@"Favorites"]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldLoadStories" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldClearComments" object:nil];
  }
  else {
    story.isFavorite = NO;
    [listView reloadData];
  }
  
  [listView setSelectedRow:selectedIndex];
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
    HNStory* story = stories[i];
    
    if (!story.isRead && !story.isFavorite)
      unreadStories++;
  }
  
  NSString* badgeString;
  
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  
  if (![userDefaults boolForKey:@"shouldShowUnreadCountInIcon"] || unreadStories == 0)
    badgeString = @"";
  else
    badgeString = [NSString stringWithFormat:@"%d", unreadStories];
  
  NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
  [tile setBadgeLabel:badgeString];
}

- (void)didRaiseConnectionFailure:(NSNotification *)notification
{
  NSError *failureError = [notification userInfo][HNConnectionControllerDidRaiseConnectionFailureErrorKey];
  if ([[failureError domain] isEqualToString:NSURLErrorDomain] && [failureError code] == NSURLErrorCancelled) {
    return;
  }
	
  loadingView.isLoading = NO;
  [failureView show];
  stories = [[NSMutableArray alloc] init];
  [listView reloadData];
}

////////////////////////////////////////////////////////////////////////
// List View Delegates
////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfRowsInListView:(PXListView*)listView {
  return [stories count];
}

- (void)listViewSelectionDidChange:(NSNotification*)aNotification
{
  if (!stories.count)
    return;
  
  selectedIndex = listView.selectedRow;
  
  if ((selectedIndex + 1) > [stories count])
    return;
  
  HNStory* story = [stories objectAtIndex:selectedIndex];
  
  id appDelegate = [[NSApplication sharedApplication] delegate];
  
  NSMenuItem* markAsReadMenuItem = [appDelegate markAsReadMenuItem];
  NSMenuItem* markAsUnreadMenuItem = [appDelegate markAsUnreadMenuItem];
  NSMenuItem* addFavoriteMenuItem = [appDelegate addFavoritesMenuItem];
  NSMenuItem* deleteFavoriteMenuItem = [appDelegate deleteFavoritesMenuItem];
  
  markAsReadMenuItem.hidden = !!story.isRead;
  markAsUnreadMenuItem.hidden = !story.isRead;
  addFavoriteMenuItem.hidden = !!story.isFavorite;
  deleteFavoriteMenuItem.hidden = !story.isFavorite;
  
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
  
  if ([category isEqualToString:@"Top"] || [category isEqualToString:@"Best"] || [category isEqualToString:@"Active"])
    [cell setNumber:row + 1.0];
  else
    [cell setNumber:nil];
  
  cell.isFavorite = !![category isEqualToString:@"Favorites"];
  
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
