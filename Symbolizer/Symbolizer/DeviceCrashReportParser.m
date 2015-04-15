//
//  DeviceCrashReportParser.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/4/2.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "DeviceCrashReportParser.h"
#import "NSString+Utility.h"
#import "Symbolizer.h"

#define PATTERN_ARCHITECTURE @"CPU Type:\\s+\\w+"
#define PATTERN_STACKADDRESS @"0x\\w+"
#define PATTERN_SLIDEADDRESS @"Slide Address:\\s+\\w+"
#define PATTERN_BASEADDRESS @"Base Address:\\s+\\w+"
#define PATTERN_ARM_IN_DEVICE_LOG @"arm\\w+"

@interface DeviceCrashReportParser()
- (NSString*)getSignalLineFromInfo:(id)info;
@end

@implementation DeviceCrashReportParser

- (NSString*)getSignalLineFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSString* str_info = info;
    NSArray* arr_lines = [str_info componentsSeparatedByString:@"\n"];
    __block NSInteger line = -1;
    [arr_lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (NSNotFound != [obj rangeOfString:@"Binary Images"].location)
        {
            line = idx;
            *stop = YES;
        }
    }];
    if (-1 != line && line + 1 < arr_lines.count)
    {
        NSInteger line_signal = line + 1;
        NSString* str_signal = arr_lines[line_signal];
        return str_signal;
    }
    return nil;
}

/**
 *  取结构
 *
 *  @param info 数据
 *
 *  @return 结构
 */
- (NSString*)getArchitectureFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSString* str_signal = [self getSignalLineFromInfo:info];
    if (str_signal)
    {
        return [NSString getFirstPartInString:str_signal expression:PATTERN_ARM_IN_DEVICE_LOG];
    }
    return nil;
}

//+ (NSString*)getStackAddressFromInfo:(id)info;

/**
 *  取Base地址
 *
 *  @param info 数据
 *
 *  @return Base地址
 */
- (NSString*)getBaseAddressFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSString* str_signal = [self getSignalLineFromInfo:info];
    if (str_signal)
    {
        return [NSString getFirstPartInString:str_signal expression:PATTERN_STACKADDRESS];
    }
    return nil;
}

/**
 *  取Slide地址
 *
 *  @param info 数据
 *
 *  @return Slide地址
 */
- (NSString*)getSlideAddressFromInfo:(id)info
{
    return nil;
}

/**
 *  取UUID
 *
 *  @param info 数据
 *
 *  @return UUID
 */
- (NSString*)getUUIDFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSString* str_signal = [self getSignalLineFromInfo:info];
    NSString* str_uuid = [NSString getFirstPartInString:str_signal expression:@"\\<\\w+\\>"];
    str_uuid = [str_uuid stringByReplacingOccurrencesOfString:@"<" withString:@""];
    str_uuid = [str_uuid stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return str_uuid;
}

/**
 *  从数据中解析
 *
 *  @param info 数据
 *
 *  @return 解析完的结果
 */
- (NSString*)symbolizeFromInfo:(id)info dsymPath:(NSString*)path
{
    //检查元素
    if (![self checkInfo:info])
    {
        return nil;
    }
    //取得必需的几个要素
    NSString* str_arch = [self getArchitectureFromInfo:info];
//    str_arch = @"armv7";
    NSString* str_base = [self getBaseAddressFromInfo:info];
    NSString* str_uuid = [self getUUIDFromInfo:info];
    if (!str_arch || !str_base || !str_uuid)
    {
        return nil;
    }
    NSString* str_uuid_executable = [Symbolizer getUUIDFromExecutablePath:path forArchitecture:str_arch];
    str_uuid_executable = [str_uuid_executable stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (NSOrderedSame != [str_uuid compare:str_uuid_executable options:NSCaseInsensitiveSearch])
    {
        return @"uuid not matched";
    }
    
    NSInteger address_base = [NSString getIntFromHexString:str_base];
    
    //取数组
    NSArray* arr_stacks = [self getStackInfoFromInfo:info];
    NSMutableString* str_result = [NSMutableString string];
    //解析
    for (NSString* str_line in arr_stacks)
    {
        [str_result appendFormat:@"%@\n", str_line];
        NSString* str_address = [NSString getFirstPartInString:str_line expression:PATTERN_STACKADDRESS];
        if (str_address)
        {
            NSInteger address_stack = [NSString getIntFromHexString:str_address];
//            NSString* str_lineResult = [Symbolizer parseInfoWithArchitechture:str_arch filePath:path slideAddress:0 baseAddress:address_base stackAddress:address_stack];
            NSString* str_lineResult = [Symbolizer parseInfoWithArchitechture:str_arch filePath:path baseAddress:address_base stackAddress:address_stack];
            [str_result appendFormat:@"%@\n", str_lineResult];
        }
    }
    //生成结果
    return str_result;
}

//@optional
- (NSArray*)getStackInfoFromInfo:(id)info
{
    if ([self checkInfo:info])
    {
        return [info componentsSeparatedByString:@"\n"];
    }
    return nil;
}

- (NSString*)getStackAddressFormLine:(NSString*)lineString
{
    if ([self checkInfo:lineString])
    {
        return [NSString getFirstPartInString:lineString expression:PATTERN_STACKADDRESS];
    }
    return nil;
}


- (BOOL)checkInfo:(id)info
{
    if ([info isKindOfClass:[NSString class]])
    {
        return YES;
    }
    return NO;
}
@end
