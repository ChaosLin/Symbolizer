//
//  CSVSymbolizerParser.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "CSVSymbolizerParser.h"
#import "NSString+Utility.h"
#import "Symbolizer.h"

#define PATTERN_ARCHITECTURE @"CPU Type:\\s+\\w+"
#define PATTERN_STACKADDRESS @"0x\\w+"
#define PATTERN_SLIDEADDRESS @"Slide Address:\\s+\\w+"
#define PATTERN_BASEADDRESS @"Base Address:\\s+\\w+"

@interface CSVSymbolizerParser()
/**
 *  检查数据是否合法，如果数据不合法不进行处理
 *
 *  @param info 数据
 *
 *  @return 是否合法
 */
- (BOOL)checkInfo:(id)info;
@end

@implementation CSVSymbolizerParser
- (NSString*)getArchitectureFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    return [info valueForKey:@"CPU Type"];
}

- (NSString*)getUUIDFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    return [info valueForKey:@"dSYM UUID"];
}

//+ (NSString*)getStackAddressFromInfo:(id)info
//{
//    if (![self checkInfo:info])
//    {
//        return [info valueForKey:@"CPU Type"];
//    }
//    return nil;
//}

- (NSString*)getBaseAddressFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSArray* stackInfo = [self getStackInfoFromInfo:info];
    if (!stackInfo || !0 == [stackInfo count])
    {
        return nil;
    }
    
    __block NSString* str_BaseAddress;
    [stackInfo enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ((str_BaseAddress = [NSString getFirstPartInString:obj expression:PATTERN_BASEADDRESS]))
        {
            str_BaseAddress = [[str_BaseAddress componentsSeparatedByString:@" "] lastObject];
            *stop = YES;
        }
    }];
    return str_BaseAddress;
}

- (NSString*)getSlideAddressFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    NSArray* stackInfo = [self getStackInfoFromInfo:info];
    if (!stackInfo || !0 == [stackInfo count])
    {
        return nil;
    }
    
    __block NSString* str_slideAddress;
    [stackInfo enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ((str_slideAddress = [NSString getFirstPartInString:obj expression:PATTERN_SLIDEADDRESS]))
        {
            str_slideAddress = [[str_slideAddress componentsSeparatedByString:@" "] lastObject];
            *stop = YES;
        }
    }];
    return str_slideAddress;
}

- (NSString*)symbolizeFromInfo:(id)info dsymPath:(NSString *)path
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    
    NSString* str_uuid = [self getUUIDFromInfo:info];
    NSString* str_arch = [self getArchitectureFromInfo:info];
    NSString* str_baseAddress = [self getBaseAddressFromInfo:info];
    NSString* str_slideAddress = [self getSlideAddressFromInfo:info];
    NSArray* arr_stack = [self getStackInfoFromInfo:info];
    if (!str_uuid || !str_arch || !str_baseAddress || !str_slideAddress || !arr_stack)
    {
        return nil;
    }
    NSString* str_uuid_executable = [Symbolizer getUUIDFromExecutablePath:path forArchitecture:str_arch];
    if (![str_uuid isEqualToString:str_uuid_executable])
    {
        return @"uuid not matched";
    }
    
    long long baseAddress = [NSString getIntFromHexString:str_baseAddress];
    long long slideAddress = [NSString getIntFromHexString:str_slideAddress];
    
    NSMutableString* str_result = [NSMutableString string];
    //取每一行数据
    for (NSString* str_line in arr_stack)
    {
        //找地址
        NSString* str_stackAddress = [self getStackAddressFormLine:str_line];
        //是否是用户的堆栈
        BOOL isUserFunction = ([str_line rangeOfString:@"???"].location != NSNotFound);
        //如果有
        if (str_stackAddress)
        {
            //symbolize
            long long stackAddress = [NSString getIntFromHexString:str_stackAddress];
            NSString* str_symbolized = nil;
            if (!isUserFunction)
            {
                str_symbolized = [Symbolizer parseInfoWithArchitechture:str_arch filePath:path slideAddress:slideAddress baseAddress:baseAddress stackAddress:stackAddress];
            }
            else
            {
                //在友盟csv的格式中每一行用户的地址已经是最终的symbolAddress了
                str_symbolized = [Symbolizer parseInfoWithArchitechture:str_arch filePath:path address:stackAddress];
            }

            if (str_symbolized)
            {
                [str_result appendFormat:@"%@\n%@\n", str_line, str_symbolized];
            }
        }
        else
        {
            [str_result appendFormat:@"%@\n", str_line];
        }
    }
    //拼字符串
    
    return str_result;
}

- (BOOL)checkInfo:(id)info
{
    return [info isKindOfClass:[NSDictionary class]];
}


- (NSString*)getStackAddressFormLine:(NSString*)lineString
{
    if (!lineString || ![lineString isKindOfClass:[NSString class]] || 0 == lineString.length)
    {
        return nil;
    }
    
    NSString* str_stackAddress = [NSString getFirstPartInString:lineString expression:PATTERN_STACKADDRESS];
    return str_stackAddress;
}

#pragma mark - optional
- (NSArray*)getStackInfoFromInfo:(id)info
{
    if (![self checkInfo:info])
    {
        return nil;
    }
    return [info valueForKey:@"错误堆栈"];
}
@end
