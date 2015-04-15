//
//  FilePathHelper.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/26.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "FilePathHelper.h"

@interface FilePathHelper()
+ (BOOL)isValidString:(NSString*)path;
@end

@implementation FilePathHelper

+ (BOOL)isValidString:(NSString*)path
{
    if (!path || ![path isKindOfClass:[NSString class]])
    {
        return NO;
    }
    return YES;
}
+ (NSString*)getDsymPathFromArchive:(NSString*)path
{
    if (![self isValidString:path])
    {
        return nil;
    }
    if (![path hasSuffix:@".xcarchive"])
    {
        return nil;
    }
    
    NSString* str_fullPath = [NSString stringWithString:path];
    NSString* str_dSYMs = @"dSYMs/";
    NSString* str_nextPath = @"Contents/Resources/DWARF/";
    //找到dSYMs
    str_fullPath = [str_fullPath stringByAppendingPathComponent:str_dSYMs];
    //找到唯一的文件
    NSError* error = nil;
    NSArray* arr_directories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:str_fullPath error:&error];
    NSString* str_temp = [arr_directories firstObject];
    if (![self isValidString:str_temp])
    {
        return nil;
    }
    str_fullPath = [str_fullPath stringByAppendingPathComponent:str_temp];
    //再往下走
    str_fullPath = [str_fullPath stringByAppendingPathComponent:str_nextPath];
    //找到唯一的文件
    arr_directories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:str_fullPath error:&error];
    str_temp = [arr_directories firstObject];
    if (![self isValidString:str_temp])
    {
        return nil;
    }
    str_fullPath = [str_fullPath stringByAppendingPathComponent:str_temp];
    return str_fullPath;
}
@end
