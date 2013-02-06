//
//  HNPostCell.m
//  Hacky
//
//  Created by Elias Klughammer on 19.11.12.
//  Copyright (c) 2012 Elias Klughammer. All rights reserved.
//

#import "HNPostCell.h"

#import <iso646.h>


@implementation HNPostCell

@synthesize number;
@synthesize topic;
@synthesize unreadButton;
@synthesize contentView;
@synthesize numberLabel;
@synthesize titleLabel;
@synthesize metaLabel;
@synthesize gearButton;
@synthesize contextMenu;
@synthesize markAsReadMenuItem;
@synthesize markAsUnreadMenuItem;

#pragma mark -
#pragma mark Init/Dealloc

- (id)initWithReusableIdentifier: (NSString*)identifier
{
	if((self = [super initWithReusableIdentifier:identifier]))
	{
    unreadButton = [[HNUnreadButton alloc] initWithFrame:CGRectMake(19, 30, 11, 11)];
    [unreadButton setTarget:self];
    [unreadButton setAction:@selector(didClickUnreadButton:)];
    [self addSubview:unreadButton];
    
    contentView = [[NSView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = NSViewWidthSizable;
    [self addSubview:contentView];
    
    numberLabel = [[NSTextField alloc] initWithFrame:CGRectMake(0, 27, 0, 20)];
    numberLabel.font = [NSFont fontWithName:@"LucidaGrande" size:12];
    [numberLabel setTextColor:[NSColor colorWithCalibratedRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0]];
    [numberLabel setEditable:NO];
    [numberLabel setBezeled:NO];
    [numberLabel setBordered:NO];
    [numberLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:numberLabel];
    
    titleLabel = [[NSTextField alloc] initWithFrame:CGRectMake(0, 27, 0, 20)];
    titleLabel.autoresizingMask = NSViewWidthSizable;
    titleLabel.font = [NSFont fontWithName:@"LucidaGrande-Bold" size:12];
    [titleLabel setEditable:NO];
    [titleLabel setBezeled:NO];
    [titleLabel setBordered:NO];
    [titleLabel setBackgroundColor:[NSColor clearColor]];
    [[titleLabel cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [contentView addSubview:titleLabel];
    
    metaLabel = [[NSTextField alloc] initWithFrame:CGRectMake(0, 8, 0, 40)];
    metaLabel.font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10];
    [metaLabel setTextColor:[NSColor colorWithCalibratedRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [metaLabel setEditable:NO];
    [metaLabel setBezeled:NO];
    [metaLabel setBordered:NO];
    [metaLabel setBackgroundColor:[NSColor clearColor]];
    [contentView addSubview:metaLabel];
    
    gearButton = [[NSButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 35, 16, 19, 19)];
    [gearButton setBordered:NO];
    [gearButton setButtonType:NSMomentaryChangeButton];
    [gearButton setImagePosition:NSImageOnly];
    [gearButton setTarget:self];
    [gearButton setAction:@selector(didClickGearButton:)];
    gearButton.hidden = YES;
    gearButton.autoresizingMask = NSViewMinXMargin;
    gearButton.image = [NSImage imageNamed:@"gear"];
    [self addSubview:gearButton];
    
    contextMenu = [[NSMenu alloc] initWithTitle:@"RightClick"];
    [contextMenu setMenuChangedMessagesEnabled:YES];
    
    NSMenuItem *openURL = [[NSMenuItem alloc] init];
    [openURL setTitle:@"Open URL"];
    [openURL setAction:@selector(didClickOpenURLButton:)];
    [openURL setTarget:self];
    [contextMenu addItem:openURL];
    
    NSMenuItem *viewComments = [[NSMenuItem alloc] init];
    [viewComments setTitle:@"View Comments"];
    [viewComments setAction:@selector(didClickViewCommentsButton:)];
    [viewComments setTarget:self];
    [contextMenu addItem:viewComments];
    
    [contextMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *copy = [[NSMenuItem alloc] init];
    [copy setTitle:@"Copy"];
    [copy setAction:@selector(didClickCopyButton:)];
    [copy setTarget:self];
    [contextMenu addItem:copy];
    
    NSMenuItem *copyURL = [[NSMenuItem alloc] init];
    [copyURL setTitle:@"Copy URL"];
    [copyURL setAction:@selector(didClickCopyURLButton:)];
    [copyURL setTarget:self];
    [contextMenu addItem:copyURL];
    
    NSMenuItem *instapaper = [[NSMenuItem alloc] init];
    [instapaper setTitle:@"Send to Instapaper"];
    [instapaper setAction:@selector(didClickInstapaperButton:)];
    [instapaper setTarget:self];
    [contextMenu addItem:instapaper];
    
    NSMenuItem *tweet = [[NSMenuItem alloc] init];
    [tweet setTitle:@"Tweet"];
    [tweet setAction:@selector(didClickTweetButton:)];
    [tweet setTarget:self];
    [contextMenu addItem:tweet];
    
    [contextMenu addItem:[NSMenuItem separatorItem]];
    
    markAsReadMenuItem = [[NSMenuItem alloc] init];
    [markAsReadMenuItem setTitle:@"Mark as Read"];
    [markAsReadMenuItem setAction:@selector(didClickMarkAsReadButton:)];
    [markAsReadMenuItem setTarget:self];
    [contextMenu addItem:markAsReadMenuItem];
    
    markAsUnreadMenuItem= [[NSMenuItem alloc] init];
    [markAsUnreadMenuItem setTitle:@"Mark as Unread"];
    [markAsUnreadMenuItem setAction:@selector(didClickMarkAsUnreadButton:)];
    [markAsUnreadMenuItem setTarget:self];
    [contextMenu addItem:markAsUnreadMenuItem];
    
    //Add the right click as the default menu
    [self setMenu:contextMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUseMenu:) name:NSMenuDidBeginTrackingNotification object:contextMenu];
	}
  
	return self;
}

- (void)setTopic:(NSMutableDictionary*)aTopic
{
  topic = aTopic;
  
  titleLabel.frame = CGRectMake(numberLabel.bounds.size.width, titleLabel.frame.origin.y, contentView.bounds.size.width - numberLabel.bounds.size.width, numberLabel.bounds.size.height);
  
  NSURL* url = [NSURL URLWithString:[topic valueForKey:@"url"]];
  titleLabel.toolTip = [url host];
  
  // Set Meta
  NSString *metaString = [NSString stringWithFormat:@"%@ Points | %@ | %@ Comments", [topic valueForKey:@"score"], [topic valueForKey:@"created_at"], [topic valueForKey:@"comments"]];
  [metaLabel setStringValue:metaString];
  [metaLabel sizeToFit];
  [metaLabel setFrameOrigin:CGPointMake(numberLabel.bounds.size.width, metaLabel.frame.origin.y)];
  
  markAsReadMenuItem.hidden = !![topic valueForKey:@"isRead"];
  markAsUnreadMenuItem.hidden = ![topic valueForKey:@"isRead"];
}

- (void)setNumber:(NSUInteger*)aNumber
{
  number = aNumber;
  numberLabel.stringValue = [NSString stringWithFormat:@"%d.", number];
  [numberLabel sizeToFit];
}

- (void)didClickGearButton:(id)sender
{
  NSRect frame = [(NSButton *)sender frame];
  NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 3.4) toView:nil];
  
  NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                       location:menuOrigin
                                  modifierFlags:NSLeftMouseDownMask
                                      timestamp:1
                                   windowNumber:[[(NSButton *)sender window] windowNumber]
                                        context:[[(NSButton *)sender window] graphicsContext]
                                    eventNumber:0
                                     clickCount:1
                                       pressure:1];
  

  [NSMenu popUpContextMenu:contextMenu withEvent:event forView:(NSButton*)sender];
}

- (void)didUseMenu:(NSNotification*)aNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didUseRightClick" object:topic];
}

- (void)didClickOpenURLButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickOpenURLMenuButton" object:nil];
}

- (void)didClickViewCommentsButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCommentsMenuButton" object:nil];
}

- (void)didClickCopyButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCopyMenuButton" object:nil];
}

- (void)didClickCopyURLButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickCopyURLMenuButton" object:nil];
}

- (void)didClickInstapaperButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickInstapaperMenuButton" object:nil];
}

- (void)didClickTweetButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickTweetMenuButton" object:nil];
}

- (void)didClickMarkAsReadButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMarkAsReadMenuButton" object:nil];
}

- (void)didClickMarkAsUnreadButton:(id)sender
{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMarkAsUnreadMenuButton" object:nil];
}

- (void)didClickUnreadButton:(id)sender
{
  NSNumber *row = [NSNumber numberWithInt:number - 1];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSelectRow" object:row];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickMarkAsReadMenuButton" object:nil];
}

#pragma mark -
#pragma mark Reuse

- (void)prepareForReuse
{
	[titleLabel setStringValue:@""];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)aRect
{
  if ([topic valueForKey:@"isRead"]) {
    titleLabel.alphaValue = 0.5;
    [contentView setFrame:CGRectMake(16, 1, self.frame.size.width - 32, 50)];
    [unreadButton setHidden:YES];
  }
  else {
    titleLabel.alphaValue = 1.0;
    [titleLabel setTextColor:[NSColor blackColor]];
    [contentView setFrame:CGRectMake(38, 1, self.frame.size.width - 38 - 18, 50)];
    [unreadButton setHidden:NO];
  }
  
  if([self isSelected]) {
    // --- Text Color
    [titleLabel setTextColor:[NSColor whiteColor]];
    [metaLabel setTextColor:[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5]];
    [numberLabel setTextColor:[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.3]];
    [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];

    NSMutableDictionary *sAttribs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [NSFont fontWithName:@"LucidaGrande-Bold" size:12], NSFontAttributeName,
                                     shadow, NSShadowAttributeName, paragraphStyle, NSParagraphStyleAttributeName, 
                                     nil];
    NSAttributedString *s = [[NSAttributedString alloc] initWithString:[topic valueForKey:@"title"] attributes:sAttribs];
    [titleLabel setAttributedStringValue:s];
    
    // --- Background Color
    [[NSColor colorWithCalibratedRed:246.0/255.0 green:246.0/255.0 blue:239.0/255.0 alpha:1.0] set];
    NSBezierPath *rect = [NSBezierPath bezierPathWithRect:aRect];
    NSGradient* gradient = [[NSGradient alloc]
                              initWithStartingColor:[NSColor colorWithCalibratedRed:17.0/255.0 green:105.0/255.0 blue:181.0/255.0 alpha:1.0]
                              endingColor:[NSColor colorWithCalibratedRed:62.0/255.0 green:154.0/255.0 blue:232.0/255.0 alpha:1.0]];
    [gradient drawInRect:[self bounds] angle:90];
    
    // --- Divider Color
    [[NSColor colorWithCalibratedRed:0.0/255.0 green:68.0/255.0 blue:141.0/255.0 alpha:1.0] set];
    
    [contentView setFrameSize:CGSizeMake(contentView.bounds.size.width - 20, contentView.bounds.size.height)];
  }
  else {
    // --- Text Color
    [titleLabel setTextColor:[NSColor blackColor]];
    [metaLabel setTextColor:[NSColor colorWithCalibratedRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [numberLabel setTextColor:[NSColor colorWithCalibratedRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0]];
    
    [titleLabel setStringValue:[topic valueForKey:@"title"]];
    
    // --- Background Color
    [[NSColor colorWithCalibratedRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] set];
  }
  
  gearButton.hidden = ![self isSelected];
  [unreadButton setSelected:[self isSelected]];
  
  // Draw divider
  NSBezierPath *divider = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, aRect.size.width, 1)];
  [divider fill];
}


#pragma mark -
#pragma mark Accessibility

- (NSArray*)accessibilityAttributeNames
{
	NSMutableArray*	attribs = [[super accessibilityAttributeNames] mutableCopy];
  
	[attribs addObject: NSAccessibilityRoleAttribute];
	[attribs addObject: NSAccessibilityDescriptionAttribute];
	[attribs addObject: NSAccessibilityTitleAttribute];
	[attribs addObject: NSAccessibilityEnabledAttribute];
  
	return attribs;
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute
{
	if( [attribute isEqualToString: NSAccessibilityRoleAttribute]
     or [attribute isEqualToString: NSAccessibilityDescriptionAttribute]
     or [attribute isEqualToString: NSAccessibilityTitleAttribute]
     or [attribute isEqualToString: NSAccessibilityEnabledAttribute] )
	{
		return NO;
	}
	else
		return [super accessibilityIsAttributeSettable: attribute];
}

- (id)accessibilityAttributeValue:(NSString*)attribute
{
	if([attribute isEqualToString:NSAccessibilityRoleAttribute])
	{
		return NSAccessibilityButtonRole;
	}
  
  if([attribute isEqualToString:NSAccessibilityDescriptionAttribute]
     or [attribute isEqualToString:NSAccessibilityTitleAttribute])
	{
		return [titleLabel stringValue];
	}
  
	if([attribute isEqualToString:NSAccessibilityEnabledAttribute])
	{
		return [NSNumber numberWithBool:YES];
	}
  
  return [super accessibilityAttributeValue:attribute];
}

@end