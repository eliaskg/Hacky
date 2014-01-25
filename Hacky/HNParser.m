//
//  HNParser.m
//  Hacky
//
//  Created by Elias Klughammer on 06.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNParser.h"
#import "HTMLParser.h"
#import "HNStory.h"

@implementation HNParser

- (NSMutableArray*)parseStories:(NSString*)response
{
  NSMutableArray *stories = [[NSMutableArray alloc] init];
  
  NSError *error = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:&error];
  
  HTMLNode *bodyNode = [parser body];
  
  NSArray* tables = [bodyNode findChildTags:@"table"];
  
  if ([tables count] < 3) {
	  return nil;
  }
  
  HTMLNode* mainTable = tables[2];
  
  NSArray* trs_ = [mainTable findChildTags:@"tr"];
  NSMutableArray* trs = [NSMutableArray arrayWithArray:trs_];
  
  // --- Remove the "more" button
  [trs removeLastObject];
  [trs removeLastObject];
  
  NSMutableDictionary* story = [[NSMutableDictionary alloc] init];
  
  for (int i = 0; i < [trs count]; i++) {
    HTMLNode* tr = trs[i];
    
    // --- First row of story (title)
    if (i % 3 == 0) {
      // --- Get title and URL
      NSArray *titleTds = [tr findChildrenOfClass:@"title"];
      HTMLNode *titleTd = [titleTds objectAtIndex:1];
      HTMLNode *titleA = [titleTd findChildTag:@"a"];
      NSString* title = [self removeLeadingAndTrailingWhitespace:[titleA contents]];
      [story setValue:title forKey:@"title"];
      NSMutableString* url = [[titleA getAttributeNamed:@"href"] mutableCopy];
      
      if (![url hasPrefix:@"https"]) {
        [url insertString:@"https://news.ycombinator.com/" atIndex:0];
      }
      
      [story setValue:url forKey:@"url"];
      
      // --- Get id
      NSArray* tds = [tr findChildTags:@"td"];
      HTMLNode* upvoteTd = [tds objectAtIndex:1];
      HTMLNode* upvoteCenter = [upvoteTd findChildTag:@"center"];
      HTMLNode* upvoteA = [upvoteCenter findChildTag:@"a"];
      NSString* upvoteId = [upvoteA getAttributeNamed:@"id"];
      NSString* storyId = [[upvoteId componentsSeparatedByString:@"_"] objectAtIndex:1];
      [story setValue:storyId forKey:@"id"];
    }
    // --- Second row of story (comment count, timestamp, etc)
    else if (i % 3 == 1) {
      NSArray* metaTds = [tr findChildrenOfClass:@"subtext"];
      HTMLNode* metaTd = [metaTds objectAtIndex:0];
      
      NSArray* metaAs = [metaTd findChildTags:@"a"];
      
      // --- Ignore sponsored stories
      if (![metaAs count])
        continue;
      
      // --- Get points
      HTMLNode* pointsSpan = [metaTd findChildTag:@"span"];
      NSString* pointsText = [pointsSpan contents];
      NSString* points = [NSString stringWithFormat:@"%li", [self numberFromString:pointsText]];
      [story setValue:points forKey:@"points"];
      
      // --- Get username
      HTMLNode* userA = [metaAs objectAtIndex:0];
      [story setValue:[userA contents] forKey:@"user"];
      
      // --- Get comments count
      HTMLNode* commentsA = [metaAs lastObject];
      NSString* commentsText = [commentsA contents];
      NSString* comments = [NSString stringWithFormat:@"%li", [self numberFromString:commentsText]];
      [story setValue:comments forKey:@"comments"];
      
      HTMLNode* createdElement = [[metaTd children] objectAtIndex:3];
      NSString* createdTextRaw = [createdElement allContents];
      NSString* createdTextNoDivider = [createdTextRaw stringByReplacingOccurrencesOfString:@"|" withString:@""];
      NSString* createdTextNoWhitespace = [self removeLeadingAndTrailingWhitespace:createdTextNoDivider];
      [story setValue:createdTextNoWhitespace forKey:@"createdAt"];
      
      // -- Add a copy of the story to the array
      NSMutableDictionary* story_ = [NSMutableDictionary dictionaryWithDictionary:story];
      
      HNStory* story = [[HNStory alloc] initWithDictionary:story_];
      
      [stories addObject:story];
    }
  }
  
  return stories;
}

- (NSMutableArray*)parseComments:(NSString*)theResponse hasURL:(BOOL)hasURL
{
  NSMutableArray* comments = [[NSMutableArray alloc] init];
  
  NSError *error = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:theResponse error:&error];
  
  HTMLNode *bodyNode = [parser body];
  
  // --- If the story is a text post, we have have to parse it as a comment
  if (hasURL) {
    NSMutableDictionary* postComment = [[NSMutableDictionary alloc] init];
    // --- If it's a text story, we need the text
    HTMLNode* mainTable = [bodyNode findChildTag:@"table"];
    NSArray* mainTables = [mainTable findChildTags:@"table"];
    HTMLNode* postTable = mainTables[1];
    NSArray* postTrs = [postTable findChildTags:@"tr"];
    
    HTMLNode* metaTr = postTrs[1];
    HTMLNode* metaContainer = [metaTr findChildOfClass:@"subtext"];
    NSArray* metaLinks = [metaContainer findChildTags:@"a"];
    HTMLNode* userLink = [metaLinks objectAtIndex:0];
    
    // --- New users are inside od a <font> tag
    HTMLNode* newUser = [userLink findChildTag:@"font"];
    NSString* userName;
    
    if (newUser)
      userName = [newUser contents];
    else
      userName = [userLink contents];
    
    [postComment setValue:userName forKey:@"user"];
    
    NSString* metaContent = [metaContainer allContents];
    NSArray* metaParts = [metaContent componentsSeparatedByString:userName];
    NSString* createdRaw = metaParts[1];
    NSArray* createdRawParts = [createdRaw componentsSeparatedByString:@"|"];
    NSString* createdWhitespace = createdRawParts[0];
    NSString* created = [self removeLeadingAndTrailingWhitespace:createdWhitespace];
    [postComment setValue:created forKey:@"created"];
    
    HTMLNode* postTr = postTrs[3];
    NSArray* postTds = [postTr findChildTags:@"td"];
    HTMLNode* postTd = postTds[1];
    NSMutableString* post = [[postTd rawContents] mutableCopy];
    [post replaceOccurrencesOfString:@"<td>" withString:@"" options:nil range:NSMakeRange(0, [post length])];
    [post replaceOccurrencesOfString:@"</td>" withString:@"" options:nil range:NSMakeRange(0, [post length])];

    [postComment setValue:post forKey:@"content"];
    
    // --- Check if the post is a poll
    if ([[postTable rawContents] rangeOfString:@"comhead\"><span id=\"score_"].location != NSNotFound) {
      HTMLNode* pollTr = postTrs[5];
      NSArray* pollTds = [pollTr findChildTags:@"td"];
      HTMLNode* pollTable = [pollTds[1] findChildTag:@"table"];
      NSArray* pollTrs = [pollTable findChildTags:@"tr"];
      
      NSMutableArray* polls = [NSMutableArray array];
      
      for (int i = 0; i < [pollTrs count]; i++) {
        HTMLNode* pollTr = pollTrs[i];
        
        if (i % 3 == 0) {
          HTMLNode* pollEntryTd = [pollTr findChildOfClass:@"comment"];
          HTMLNode* pollEntryDiv = [pollEntryTd findChildTag:@"div"];
          HTMLNode* pollEntryFont = [pollEntryDiv findChildTag:@"font"];
          NSString* title = [pollEntryFont contents];
          
          NSMutableDictionary* poll = [NSMutableDictionary dictionary];
          [poll setValue:title forKey:@"title"];
          
          [polls addObject:poll];
        }
        else if (i % 3 == 1) {
          HTMLNode* pollEntryTd = [pollTr findChildOfClass:@"default"];
          HTMLNode* pollEntrySpan1 = [pollEntryTd findChildTag:@"span"];
          HTMLNode* pollEntrySpan2 = [pollEntrySpan1 findChildTag:@"span"];
          NSArray* pointParts = [[pollEntrySpan2 contents] componentsSeparatedByString:@" points"];
          NSString* points = [pointParts objectAtIndex:0];
          
          NSMutableDictionary* poll = [polls lastObject];
          [poll setValue:points forKey:@"points"];
        }
      }
      
      [postComment setValue:polls forKey:@"poll"];
    }
    
    [postComment setValue:@"true" forKey:@"isPost"];
    
    [postComment setValue:@"0" forKey:@"margin"];
    
    [comments addObject:postComment];
  }
  
  NSArray* commentContainers = [bodyNode findChildrenOfClass:@"comment"];
  
  for (int i = 0; i < [commentContainers count]; i++) {
    NSMutableDictionary *comment = [[NSMutableDictionary alloc] init];
    
    HTMLNode* commentContainer = [commentContainers objectAtIndex:i];
    [comment setValue:[commentContainer rawContents] forKey:@"content"];
    
    HTMLNode* parentContainer = [commentContainer parent];
    HTMLNode* metaContainer = [parentContainer findChildOfClass:@"comhead"];
    
    NSArray* metaLinks = [metaContainer findChildTags:@"a"];
    
    // --- If it was a deleted comment, ignore it
    if ([metaLinks count] == 0)
      continue;
    
    HTMLNode* userLink = [metaLinks objectAtIndex:0];
    HTMLNode* idLink = [metaLinks objectAtIndex:1];
    
    // --- New users are inside od a <font> tag
    HTMLNode* newUser = [userLink findChildTag:@"font"];
    NSString* userName;
    
    if (newUser)
      userName = [newUser contents];
    else
      userName = [userLink contents];

    [comment setValue:userName forKey:@"user"];
    
    NSString* idHref = [idLink getAttributeNamed:@"href"];
    NSArray* linkParts = [idHref componentsSeparatedByString:@"="];
    NSString* commentId = [linkParts objectAtIndex:1];
    [comment setValue:commentId forKey:@"id"];
    
    NSString* metaContent = [metaContainer allContents];
    NSArray* metaParts = [metaContent componentsSeparatedByString:userName];
    NSString* createdRaw = metaParts[1];
    NSArray* createdRawParts = [createdRaw componentsSeparatedByString:@"|"];
    NSString* createdWhitespace = createdRawParts[0];
    NSString* created = [self removeLeadingAndTrailingWhitespace:createdWhitespace];
    [comment setValue:created forKey:@"created"];
  
    HTMLNode* marginImage = [[parentContainer parent] findChildTag:@"img"];
    NSString* marginString = [marginImage getAttributeNamed:@"width"];
    [comment setValue:marginString forKey:@"margin"];
    
    [comments addObject:comment];
  }
  
  return comments;
}

- (NSInteger)numberFromString:(NSString*)string
{
  // Input
  NSString *originalString = string;
  
  // Intermediate
  NSString *numberString;
  
  NSScanner *scanner = [NSScanner scannerWithString:originalString];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
  
  // Throw away characters before the first number.
  [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
  
  // Collect numbers.
  [scanner scanCharactersFromSet:numbers intoString:&numberString];
  
  // Result.
  long number = [numberString integerValue];
  
  return number;
}

-(NSString*)removeLeadingAndTrailingWhitespace:(NSString*)string {
  NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
  NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
  
  NSArray *parts = [string componentsSeparatedByCharactersInSet:whitespaces];
  NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
  
  return [filteredArray componentsJoinedByString:@" "];
}

@end
