//
//  HNCategorySelector.m
//  Hacky
//
//  Created by Elias Klughammer on 02.03.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNCategorySelector.h"

@implementation HNCategorySelector

@synthesize title;
@synthesize titleLabel;
@synthesize dropDownImageView;
@synthesize dropDownImageNormal;
@synthesize dropDownImageActive;
@synthesize trackingArea;
@synthesize menu;

- (id)init
{
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    titleLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    [titleLabel setEditable:NO];
    [titleLabel setBezeled:NO];
    [titleLabel setBordered:NO];
    [titleLabel setBackgroundColor:[NSColor clearColor]];
    [titleLabel setFrameOrigin:NSMakePoint(self.bounds.size.width / 2, self.bounds.size.height / 2)];
    [self addSubview:titleLabel];
    
    dropDownImageNormal = [NSImage imageNamed:@"categorySelectorNormal"];
    dropDownImageActive = [NSImage imageNamed:@"categorySelectorActive"];
    
    dropDownImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-7, 4, 7, 5)];
    dropDownImageView.image = dropDownImageNormal;
    dropDownImageView.autoresizingMask = NSViewMinXMargin;
    [self addSubview:dropDownImageView];
    
    menu = [[NSMenu alloc] initWithTitle:@"Category"];
    [menu setMenuChangedMessagesEnabled:YES];
    
    NSMenuItem *topMenu = [[NSMenuItem alloc] init];
    [topMenu setTitle:@"Top"];
    [topMenu setAction:@selector(didClickMenuButton:)];
    [topMenu setTarget:self];
    [menu addItem:topMenu];
    
    NSMenuItem *newMenu = [[NSMenuItem alloc] init];
    [newMenu setTitle:@"New"];
    [newMenu setAction:@selector(didClickMenuButton:)];
    [newMenu setTarget:self];
    [menu addItem:newMenu];
    
    NSMenuItem *askMenu = [[NSMenuItem alloc] init];
    [askMenu setTitle:@"Ask"];
    [askMenu setAction:@selector(didClickMenuButton:)];
    [askMenu setTarget:self];
    [menu addItem:askMenu];
    
    NSMenuItem *favoritesMenu = [[NSMenuItem alloc] init];
    [favoritesMenu setTitle:@"Favorites"];
    [favoritesMenu setAction:@selector(didClickMenuButton:)];
    [favoritesMenu setTarget:self];
    [menu addItem:favoritesMenu];
  }
  
  return self;
}

- (void)setTitle:(NSString *)theTitle
{
  if ([theTitle isEqualToString:title])
    return;
  
  title = theTitle;
  
  titleLabel.stringValue = title;
  
  NSShadow *shadow = [[NSShadow alloc] init];
  [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.3]];
  [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
  // Create the attributes dictionary, you can change the font size
  // to whatever is useful to you
  NSMutableDictionary *sAttribs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [NSFont fontWithName:@"LucidaGrande" size:13],NSFontAttributeName,
                                   shadow, NSShadowAttributeName,
                                   nil];
  // Create a new attributed string with your attributes dictionary attached
  NSAttributedString *s = [[NSAttributedString alloc] initWithString:title attributes:sAttribs];
  // Set your text value
  [titleLabel setAttributedStringValue:s];
  
  [titleLabel sizeToFit];
  
  [self fitAndCenter];
}

- (void)fitAndCenter
{
  [self setFrameSize:NSMakeSize(titleLabel.bounds.size.width + 2 + 7, titleLabel.bounds.size.height)];
  [self setFrameOrigin:NSMakePoint(self.superview.bounds.size.width / 2 - self.bounds.size.width / 2,
                                   self.superview.bounds.size.height / 2 - self.bounds.size.height / 2)];
}

-(void)updateTrackingAreas
{
  if(trackingArea != nil) {
    [self removeTrackingArea:trackingArea];
    trackingArea = nil;
  }
  
  int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
  trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                              options:opts
                                                owner:self
                                            userInfo:nil];
  [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
  dropDownImageView.image = dropDownImageActive;
}

- (void)mouseExited:(NSEvent *)theEvent
{
  dropDownImageView.image = dropDownImageNormal;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSRect frame = [dropDownImageView frame];
  NSPoint menuOrigin = [self convertPoint:NSMakePoint(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height / 3.4) toView:nil];
  
  NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                       location:menuOrigin
                                  modifierFlags:NSLeftMouseDownMask
                                      timestamp:1
                                   windowNumber:[[self window] windowNumber]
                                        context:[[self window] graphicsContext]
                                    eventNumber:0
                                     clickCount:1
                                       pressure:1];
  
  
  [NSMenu popUpContextMenu:menu withEvent:event forView:dropDownImageView];
}

- (void)setCategory:(NSString*)theCategory
{
  if ([theCategory isEqualToString:title])
    return;
  
  [self setTitle:theCategory];
  
  NSArray* menuItems = menu.itemArray;
  
  // --- Set check mark
  for (int i = 0; i < [menuItems count]; i++) {
    NSMenuItem* menuItem = menuItems[i];
    
    if ([menuItem.title isEqualToString:theCategory])
      menuItem.state = NSOnState;
    else
      menuItem.state = NSOffState;
  }
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:theCategory forKey:@"selectedCategory"];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectCategory" object:theCategory];
}

- (void)didClickMenuButton:(NSMenuItem*)sender
{
  [self setCategory:sender.title];
}

@end
