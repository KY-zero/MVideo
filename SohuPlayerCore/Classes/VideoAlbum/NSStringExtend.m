//
//  NSStringExtend.m
//  fushihui
//
//  Created by jinzhu on 10-8-11.
//  Copyright 2010 Sharppoint Group All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import <CoreFoundation/CoreFoundation.h>
#import "NSStringExtend.h"


#pragma mark -
@implementation NSString(ExtendedForUrlComponents)
- (NSString *)stringByAppendingUrlComponent:(NSString *)urlComponent
{	
	if(urlComponent == nil || [urlComponent length] == 0)
		return self;
	
	NSString *url = self;
	int len = [url length];
	unichar tail = [url characterAtIndex:len-1];
	unichar head = [urlComponent characterAtIndex:0];
	unichar sep = (unichar)'/';
	if(tail != sep && head != sep)
	{
		url = [url stringByAppendingString:@"/"];
	}
	url = [url stringByAppendingString:urlComponent];
	return url;
}

- (NSString *)stringByAppendingUrlParameter:(NSString *)param forKey:(NSString *)key
{
	NSString *url = self;
	NSRange ret = [url rangeOfString:@"?"];
	if(ret.location == NSNotFound)
	{
		url = [url stringByAppendingFormat:@"?%@=%@", key, param];
	}
	else
	{
		url = [url stringByAppendingFormat:@"&%@=%@", key, param];
	}
	
	return url;
}

- (NSString *)stringByAddPrefix:(NSString *)prefix
{
	NSString *url = self;
	if (![url hasPrefix:prefix]) 
	{
		//NSAssert(0, (@"url missing the prefix:%@",url)); 
		url = [NSString stringWithFormat:@"%@%@",prefix,url];
		
	}
	return url;
}

- (BOOL)isNmuberString
{
    BOOL isNmuberString = NO;
    long long int n = [self longLongValue];
    if (n < 18999999999 && n > 13000000000) {
        isNmuberString = YES;
    }
    return isNmuberString;
} 

- (BOOL)isEmailString 
{
    BOOL isEmailString = NO;
    NSRange range = [self rangeOfString:@"@"];
    if (range.length > 0) {
        isEmailString = YES;
    }
    return isEmailString;
}

@end


#pragma mark -
@implementation NSString(URLEncodeExtended)

+ (NSString*)stringWithStringEncodeUTF8:(NSString *)strToEncode
{
	if (strToEncode == nil ) {
		return @"";	
	}
	
	return [strToEncode urlEncodedStringUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)encodedUTF8String
{
	return [self urlEncodedStringUsingEncoding:NSUTF8StringEncoding];
}


+ (NSString*)stringWithStringUrlEncoded:(NSString *)strToEncode usingEncoding:(NSStringEncoding)encoding
{
	if (strToEncode == nil ) {
		return @"";	
	}
	
	return [strToEncode urlEncodedStringUsingEncoding:encoding];
}

- (NSString *)urlEncodedStringUsingEncoding:(NSStringEncoding)encoding
{
	CFStringEncoding cfencoding = CFStringConvertNSStringEncodingToEncoding(encoding);

	return [self urlEncodedUsingCFStringEncoding:cfencoding alreadyPercentEscaped: NO];
}

- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding alreadyPercentEscaped:(BOOL)percentEscaped
{
    //CFStringRef nonAlphaNumValidChars = CFSTR("![ DISCUZ_CODE_1 ]’()*+,-./:;=?@_~");
	CFStringRef nonAlphaNumValidChars = CFSTR("![ ]’()*+,-./:;=?@_~&");
	CFStringRef preprocessedString = NULL;
    if(percentEscaped)
    {
        preprocessedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), cfencoding);
    }
	CFStringRef newStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,preprocessedString ? preprocessedString : (CFStringRef)self,
                                                                 NULL,nonAlphaNumValidChars, cfencoding);
	if(preprocessedString)
    {
        CFRelease(preprocessedString);
    }
	NSString *re = [NSString stringWithFormat:@"%@",(NSString *)newStr];
	CFRelease(newStr);
	return re;
}

- (NSString *)urlDedcodeStringUsingEncoding:(NSStringEncoding)encoding
{
	CFStringEncoding cfencoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    
	return [self urlDecodeUsingCFStringEncoding:cfencoding alreadyPercentEscaped: NO];
}

- (NSString *)urlDecodeUsingCFStringEncoding:(CFStringEncoding)cfencoding alreadyPercentEscaped:(BOOL)percentEscaped
{
	CFStringRef newStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), cfencoding);
    NSString *re = self;
    if (newStr) {
        re = [NSString stringWithFormat:@"%@",(NSString *)newStr];
        CFRelease(newStr);
    }
    
	return re;
}

- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding
{
    return [self urlEncodedUsingCFStringEncoding: cfencoding alreadyPercentEscaped:YES];
}


@end

#pragma mark -
@implementation NSString (CoreTextExtention)

- (NSArray *)splitStringWithFont:(UIFont *)font constrainedToWidth:(CGFloat)lineWidth {
	CGRect box = CGRectMake(0,0, lineWidth, CGFLOAT_MAX);
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, box);
	
	CFMutableAttributedStringRef _attributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	int length = CFAttributedStringGetLength(_attributedString);
	CFAttributedStringReplaceString(_attributedString, CFRangeMake(0, length), (CFStringRef)self);
	CGFloat pointSize = [font pointSize];
	CTFontRef myFont = CTFontCreateWithName((CFStringRef)[font fontName], pointSize, NULL); 
	int newLength = CFStringGetLength((CFStringRef)self);
	CFAttributedStringSetAttribute(_attributedString, CFRangeMake(0, newLength), kCTFontAttributeName, myFont);
	CFRelease(myFont);
	CTFramesetterRef _framesetter = CTFramesetterCreateWithAttributedString(_attributedString);
	CFRelease(_attributedString);
	
	// Create a frame for this column and draw it.
	CTFrameRef _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, NULL);
	
    CFRelease(path);
    //{ added cxt 2011-12-31
    CFRelease(_framesetter);
    
	CFArrayRef _lineArray = CTFrameGetLines(_frame);
	NSMutableArray *returnedArray = [NSMutableArray array];
	CTLineRef oneLine = NULL;
	CFRange oneRange;
	NSString *oneSubString = NULL;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	for (int i = 0; i < CFArrayGetCount(_lineArray); i++) {
		oneLine = CFArrayGetValueAtIndex(_lineArray, i);
		oneRange = CTLineGetStringRange(oneLine);
		oneSubString = [self substringWithRange:NSMakeRange(oneRange.location, oneRange.length)];
		[returnedArray addObject:oneSubString];
	}
    CFRelease(_frame);
	[pool drain];
	return returnedArray;
}

@end


#pragma mark -
@implementation NSString (WhitespaceExtention)

- (NSString *) trimmedString {
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [trimmedString length] ? trimmedString : nil;
}

- (BOOL)isWhitespaceAndNewlines {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}


- (BOOL)isEmptyOrWhitespace {
    // A nil or NULL string is not the same as an empty string
    return 0 == self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

@end


