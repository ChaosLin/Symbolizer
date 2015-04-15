//
//  CSVParser.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "CSVParser.h"
#define STRING_QUOTE @"\", \""
#define STRING_SEPERATE @"\"seperate\""

@implementation CSVParser

+ (NSArray*)parseDataInfo:(NSString*)info
{
    NSMutableArray* arr_result = [NSMutableArray array];
    if (!info || ![info isKindOfClass:[NSString class]] || 0 == info.length)
    {
        return nil;
    }
    NSArray* arr_strLines = [info componentsSeparatedByString:@"\n"];
    if (0 >= arr_strLines.count)
    {
        return nil;
    }
    
    //处理head
    NSArray* arr_head_key = [self parseLineFromInfo:[arr_strLines firstObject]];
    if (0 >= arr_head_key.count)
    {
        return nil;
    }
    
    //处理每一行
    for (NSInteger i = 1; i < arr_strLines.count; i ++)
    {
        NSString* str_line = arr_strLines[i];
        NSArray* arr_lineResult = [self parseLineFromInfo:str_line];
        //处理对应关系
        NSMutableDictionary* dic_line = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < arr_head_key.count; i ++)
        {
            NSString* str_key = arr_head_key[i];
            NSString* str_value = (i < arr_lineResult.count?arr_lineResult[i]:nil);
            if (str_value)
            {
                [dic_line setValue:str_value forKey:str_key];
            }
        }
        [arr_result addObject:dic_line];
    }
    return arr_result;
}

+ (NSArray*)parseLineFromInfo:(NSString*)info
{
    NSString* str_info = info;
    NSMutableArray* arr_result = [NSMutableArray array];
    if (!info || ![info isKindOfClass:[NSString class]] || 0 == info.length)
    {
        return arr_result;
    }
    //have", "?
    BOOL hasQuote = ([info rangeOfString:STRING_QUOTE].location != NSNotFound);
    if (hasQuote)
    {
        //replace
        str_info = [str_info stringByReplacingOccurrencesOfString:STRING_QUOTE withString:STRING_SEPERATE];
    }
    //seperate by ,
    NSArray* arr_seperated = [str_info componentsSeparatedByString:@","];
    [arr_result addObjectsFromArray:arr_seperated];
    //enumerator
    NSMutableArray* arr_replacePair = [NSMutableArray array];
    for (NSInteger i = 0; i < arr_result.count; i++)
    {
        NSString* str_part = [arr_result objectAtIndex:i];
        //has seperator?
        if (NSNotFound != [str_part rangeOfString:STRING_SEPERATE].location)
        {
            //if yes
            //sperator
            [arr_replacePair addObject:@(i)];
            NSArray* arr_subParts = [str_part componentsSeparatedByString:STRING_SEPERATE];
            [arr_replacePair addObject:arr_subParts];
        }
    }
    //replace
    for (NSInteger i = 0;i <= (NSInteger)(arr_replacePair.count) - 2; i+=2)
    {
        NSInteger index  = [[arr_replacePair objectAtIndex:i] integerValue];
        NSArray* arr_parts = [arr_replacePair objectAtIndex:i + 1];
        [arr_result replaceObjectAtIndex:index withObject:arr_parts];
    }
    
    return arr_result;
}

+ (NSArray*)parseFile:(NSString*)filePath
{
    NSString* str_file = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self parseDataInfo:str_file];
}
@end
