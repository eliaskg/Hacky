//
//  HNParser.m
//  Hacky
//
//  Created by Elias Klughammer on 06.02.13.
//  Copyright (c) 2013 Elias Klughammer. All rights reserved.
//

#import "HNParser.h"
#import "HTMLParser.h"

@implementation HNParser

- (NSMutableArray*)parseStories:(NSString*)response
{
  NSMutableArray *stories = [[NSMutableArray alloc] init];
  
  NSError *error = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:&error];
  
  HTMLNode *bodyNode = [parser body];
  
  NSArray* tables = [bodyNode findChildTags:@"table"];
  
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
      [story setValue:[titleA contents] forKey:@"title"];
      [story setValue:[titleA getAttributeNamed:@"href"] forKey:@"url"];
      
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
      
      // --- Get score
      HTMLNode* scoreSpan = [metaTd findChildTag:@"span"];
      NSString* scoreText = [scoreSpan contents];
      NSString* score = [NSString stringWithFormat:@"%li", [self numberFromString:scoreText]];
      [story setValue:score forKey:@"score"];
      
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
      [story setValue:createdTextNoWhitespace forKey:@"created_at"];
      
      // -- Add a copy of the story to the array
      NSMutableDictionary* story_ = [NSMutableDictionary dictionaryWithDictionary:story];
      [stories addObject:story_];
      //      j++;
    }
  }
  
  return stories;
}

- (NSMutableArray*)parseComments:(NSString*)response
{
  NSMutableArray* comments = [[NSMutableArray alloc] init];
  
  NSError *error = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:&error];
  
  HTMLNode *bodyNode = [parser body];
  
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
    NSString* commentsId = [linkParts objectAtIndex:1];
    [comment setValue:commentsId forKey:@"id"];
    
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
