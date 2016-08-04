//
//  NSStringExtend.h
//  fushihui
//
//  Created by jinzhu on 10-8-11.
//  Copyright 2010 Sharppoint Group All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark -
@interface NSString(ExtendedForUrlComponents)
- (NSString *)stringByAppendingUrlComponent:(NSString *)urlComponent;
- (NSString *)stringByAppendingUrlParameter:(NSString *)param forKey:(NSString *)key;
- (NSString *)stringByAddPrefix:(NSString *)prefix;

- (NSString *)stringByReplaceUrlHost:(NSString *)newHost;
- (BOOL)isAppUrlString;
- (BOOL)isNmuberString;
- (BOOL)isEmailString;
@end



#pragma mark -
@interface NSString(URLEncodeExtended)

+ (NSString*)stringWithStringEncodeUTF8:(NSString *)strToEncode;
- (NSString *)encodedUTF8String;

+ (NSString*)stringWithStringUrlEncoded:(NSString *)strToEncode usingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlEncodedStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlDedcodeStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding;
- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding alreadyPercentEscaped:(BOOL)percentEscaped;
- (NSString *)urlDecodeUsingCFStringEncoding:(CFStringEncoding)cfencoding alreadyPercentEscaped:(BOOL)percentEscaped;
@end

#pragma mark -
@interface NSString (CoreTextExtention)
- (NSArray *)splitStringWithFont:(UIFont *)font constrainedToWidth:(CGFloat)lineWidth;
@end


#pragma mark -
@interface NSString (WhitespaceExtention)
- (id) trimmedString;
- (BOOL)isWhitespaceAndNewlines;
- (BOOL)isEmptyOrWhitespace;
@end

