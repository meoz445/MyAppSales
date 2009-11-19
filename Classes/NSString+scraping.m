//
//  NSString+scraping.m
//  ASiST
//
//  Created by Oliver on 26.10.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "NSString+scraping.h"


@implementation NSString (scraping)


- (NSDictionary *)dictionaryOfAttributesFromTag
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	NSString *stringToScan = self;
	
	NSScanner *attributeScanner = [NSScanner scannerWithString:stringToScan];
	
	//NSMutableArray *attributeArray = [NSMutableArray array];
	
	// skip leading <tagname

	NSString *temp;

	if ([attributeScanner scanString:@"<" intoString:&temp])
	{
		[attributeScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
		[attributeScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&temp];
		[attributeScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
	}
	
	while (![attributeScanner isAtEnd])
	{
		
		NSString *attrName;
		NSString *attrValue;
		
		[attributeScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
		[attributeScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&attrName];
		[attributeScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
		[attributeScanner scanString:@"=" intoString:nil];
		[attributeScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&temp];
		
		if ([attributeScanner scanString:@"\"" intoString:&temp])
		{
			[attributeScanner scanUpToString:@"\"" intoString:&attrValue];	
			[attributeScanner scanString:@"\"" intoString:&temp];
			
			[tmpDict setObject:attrValue forKey:attrName];
		}
		else
		{
			// no attribute found, scan to the end
			[attributeScanner setScanLocation:[self length]];
		}
	}
	
	if ([tmpDict count])
	{
		return [NSDictionary dictionaryWithDictionary:tmpDict];
	}
	else 
	{
		return nil;
	}
}



- (NSArray *)arrayOfInputs
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	NSScanner *inputScanner = [NSScanner scannerWithString:self];
	
	while (![inputScanner isAtEnd]) 
	{
		[inputScanner scanUpToString:@"<input " intoString:nil];
		if ([inputScanner scanString:@"<input " intoString:nil])
		{
			
			NSString *inputAttributes;
			
			
			
			[inputScanner scanUpToString:@">" intoString:&inputAttributes];
			
			[tmpArray addObject:[inputAttributes dictionaryOfAttributesFromTag]];
		}
	}
	
	if ([tmpArray count])
	{
		return [NSArray arrayWithArray:tmpArray];
	}
	else 
	{
		return nil;
	}
}

- (NSArray *)arrayOfInputsForForm:(NSString *)formName
{
	NSScanner *inputScanner = [NSScanner scannerWithString:self];
	
	while (![inputScanner isAtEnd]) 
	{
		[inputScanner scanUpToString:@"<form " intoString:nil];
		if ([inputScanner scanString:@"<form " intoString:nil])
		{
			
			NSString *inputAttributes;
			
			[inputScanner scanUpToString:@"</form>" intoString:&inputAttributes];
			
			NSDictionary *formAttributes = [inputAttributes dictionaryOfAttributesFromTag];
			
			if ([[formAttributes objectForKey:@"name"] isEqualToString:formName])
			{
				return [inputAttributes arrayOfInputs];
			}
		}
	}
	return nil;
}

- (NSString *)tagHTMLforTag:(NSString *)tag WithName:(NSString *)name
{
	NSScanner *inputScanner = [NSScanner scannerWithString:self];
	
	NSString *beginTag = [NSString stringWithFormat:@"<%@ ", tag];
	NSString *endTag = [NSString stringWithFormat:@"</%@>", tag];
	
	
	while (![inputScanner isAtEnd]) 
	{
		[inputScanner scanUpToString:beginTag intoString:nil];
		if ([inputScanner scanString:beginTag intoString:nil])
		{
			
			NSString *inputAttributes;
			
			[inputScanner scanUpToString:endTag intoString:&inputAttributes];
			
			NSDictionary *formAttributes = [inputAttributes dictionaryOfAttributesFromTag];
			
			if ([[formAttributes objectForKey:@"name"] isEqualToString:name])
			{
				return [NSString stringWithFormat:@"%@%@%@", beginTag, inputAttributes, endTag];
			}
		}
	}
	return nil;
}

- (NSString *)tagHTMLforTag:(NSString *)tag WithID:(NSString *)identifier
{
	NSScanner *inputScanner = [NSScanner scannerWithString:self];
	
	NSString *beginTag = [NSString stringWithFormat:@"<%@ ", tag];
	NSString *endTag = [NSString stringWithFormat:@"</%@>", tag];
	
	
	while (![inputScanner isAtEnd]) 
	{
		[inputScanner scanUpToString:beginTag intoString:nil];
		if ([inputScanner scanString:beginTag intoString:nil])
		{
			
			NSString *inputAttributes;
			
			[inputScanner scanUpToString:endTag intoString:&inputAttributes];
			
			NSDictionary *formAttributes = [inputAttributes dictionaryOfAttributesFromTag];
			
			for (NSString *oneAttributeKey in [formAttributes allKeys])
			{
				if ([[oneAttributeKey lowercaseString] isEqualToString:@"id"])
				{
					if ([[formAttributes objectForKey:oneAttributeKey] isEqualToString:identifier])
					{
						return [NSString stringWithFormat:@"%@%@%@", beginTag, inputAttributes, endTag];
					}
				}
			}
		}
	}
	return nil;
}

- (NSString *)nameForTag:(NSString *)tag WithID:(NSString *)identifier
{
	NSString *html = [self tagHTMLforTag:tag WithID:identifier];
	NSDictionary *attributes = [html dictionaryOfAttributesFromTag];
	
	return [attributes objectForKey:@"name"];
}

@end
