//
//  NSString+Utility.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)

+ (NSString*)getFirstPartInString:(NSString*)string expression:(NSString*)expression
{
    NSError* error = nil;
    NSRegularExpression* regularExpression = [[NSRegularExpression alloc]initWithPattern:expression options:0 error:&error];
    if (error)
    {
        NSException* exception = [NSException new];
        @throw exception;
    }
    NSRange range_string;
    range_string.location = 0;
    range_string.length = string.length;
    NSRange range = [regularExpression rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:range_string];
    //    - (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
    NSString* str_result = nil;
    if (NSNotFound != range.location)
    {
        str_result = [string substringWithRange:range];
    }
    return str_result;
}


+ (unsigned long long)getIntFromHexString:(NSString*)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    unsigned long long n = 0;
    
    [scan scanHexLongLong:&n];
    return n;
}

+ (NSString*)getLogFileWithPath:(NSString*)path
{
    NSError* error = nil;
    NSString* str_log = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Read logFile error: %@", error);
    }
    return str_log;
}

/**
 *  判断一个字符串是否valid
 *
 *  @param string 要判断的字符串
 *
 *  @return Yes if not nil and isKindOfClass NSString and 0 < length
 */
+ (BOOL)isValidString:(NSString*)string
{
    if (string && [string isKindOfClass:[NSString class]] && 0 < string.length)
    {
        return YES;
    }
    return NO;
}
@end
