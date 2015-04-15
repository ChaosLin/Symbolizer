//
//  Symbolizer.m
//  test_address
//
//  Created by RentonTheUncoped on 15/3/17.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "Symbolizer.h"
#import "NSString+Utility.h"
#import "SymbolizerParserProtocol.h"
#import "CSVSymbolizerParser.h"
#import "DeviceCrashReportParser.h"
#import "CSVParser.h"
#import "AlertHelper.h"
#import "TaskHelper.h"

#define PATTERN_ARCHITECTURE    @"CPU Type:\\s+\\w+"
#define PATTERN_STACKADDRESS    @"0x\\w+"
#define PATTERN_SLIDEADDRESS    @"Slide Address:\\s+\\w+"
#define PATTERN_BASEADDRESS     @"Base Address:\\s+\\w+"
#define PATTERN_UUID_UMENG      @"dSYM\\s+UUID:\\s+\\w+\\-\\w+\\-\\w+\\-\\w+\\-\\w+"
#define PATTERN_UUID            @"\\w+\\-\\w+\\-\\w+\\-\\w+\\-\\w+"

static id<SymbolizerParserProtocol> parser = nil;
@interface Symbolizer()

/**
 *  取Architecture
 *
 *  @param log 文件内容
 *
 *  @return Architecture
 */
+ (NSString*)getArchFromSingleLog:(NSString*)log;

/**
 *  取Slide地址
 *
 *  @param log 文件内容
 *
 *  @return Slide地址
 */
+ (NSString*)getSlideFromSingleLog:(NSString*)log;

/**
 *  取Base地址
 *
 *  @param log 文件内容
 *
 *  @return Base地址
 */
+ (NSString*)getBaseFromSingleLog:(NSString*)log;
@end

@implementation Symbolizer

+ (NSString*)parseInfoWithArchitechture:(NSString*)arch filePath:(NSString*)path address:(NSInteger)address
{
    NSString* str_address = [NSString stringWithFormat:@"%lx", (long)address];
    NSString* str_launchPath = @"/usr/bin/atos";
    NSArray* arr_arguments = @[@"-arch", arch, @"-o", path, str_address];
    
    NSString* str_result = [TaskHelper getResultFromTaskWithPath:str_launchPath arguments:arr_arguments];
    return str_result;
}

+ (NSString*)parseInfoWithArchitechture:(NSString*)arch filePath:(NSString*)path slideAddress:(NSInteger)address_slide baseAddress:(NSInteger)address_base stackAddress:(NSInteger)address_stack
{
    return [self parseInfoWithArchitechture:arch filePath:path address:address_slide + address_stack - address_base];
}

/**
 *  符号化,参数为loadAddress和stackAddress，适用于解析真机的crashReport
 *
 *  @param arch          结构
 *  @param path          包的地址
 *  @param address_base  base地址
 *  @param address_stack 栈的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseInfoWithArchitechture:(NSString *)arch filePath:(NSString *)path baseAddress:(NSInteger)address_base stackAddress:(NSInteger)address_stack
{
    if (!arch || !path || 0 >= address_base || 0 >= address_stack)
    {
        return nil;
    }
    
    NSString* str_address = [NSString stringWithFormat:@"%lx", (long)address_stack];
    NSString* str_loadAddress = [NSString stringWithFormat:@"%lx", (long)address_base];
    
    NSString* str_result = [TaskHelper getResultFromTaskWithPath:@"/usr/bin/atos" arguments:@[@"-arch", arch, @"-o", path, @"-l", str_loadAddress, str_address]];
    
    return str_result;
}

#pragma mark - 适用于单一文件的解析
/**
 *  从日志信息里面符号化
 *
 *  @param log  日志信息
 *  @param path 包的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseLog:(NSString*)log executablePath:(NSString*)path
{
    NSMutableString* str_result = nil;
    //取结构arch
    NSString* arch = [self getArchFromSingleLog:log];
    //取slideAddress
    NSString* str_slideAddress = [self getSlideFromSingleLog:log];
    long long slideAddress = [NSString getIntFromHexString:str_slideAddress];
    //取baseAddress
    NSString* str_baseAddress = [self getBaseFromSingleLog:log];
    long long baseAddress = [NSString getIntFromHexString:str_baseAddress];
    //取当前崩溃的uuid
    NSString* str_uuid_report = [self getUUIDFromSingleLog:log];
    
    if (!arch || !str_slideAddress || !str_baseAddress || !str_uuid_report)
    {
        return str_result;
    }
    
    //取当前executable uuid
    NSString* str_uuid_executable = [self getUUIDFromExecutablePath:path forArchitecture:arch];
    if (![str_uuid_executable isEqualToString:str_uuid_report])
    {
        return str_result;
    }
    
    //取每一行数据
    NSArray* arr_lines = [log componentsSeparatedByString:@"\n"];
    
    for (NSString* str_line in arr_lines)
    {
        //如果需要处理
        NSString* str_address = [NSString getFirstPartInString:str_line expression:PATTERN_STACKADDRESS];
        //写字符串
        [str_result appendString:str_line];
        [str_result appendString:@"\n"];
        if (str_address && NSNotFound != [str_result rangeOfString:@"??"].location)
//        if (str_address)
        {
            long long address = [NSString getIntFromHexString:str_address];
            //parse
            NSString* str_parse = [self parseInfoWithArchitechture:arch filePath:path slideAddress:slideAddress baseAddress:baseAddress stackAddress:address];
            //写字符串
            if (str_parse)
            {
                [str_result appendString:str_parse];
                [str_result appendString:@"\n"];
            }
        }
    }
    
    return str_result;
}

/**
 *  从单一的日志文件符号化
 *
 *  @param logFilePath 日志文件路径
 *  @param path        包的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseLogFile:(NSString*)logFilePath executablePath:(NSString *)path
{
    NSMutableString* str_result = [NSMutableString string];
    //读取logfile
    NSString* str_log = [NSString getLogFileWithPath:logFilePath];
    if (!str_log)
    {
        return str_result;
    }
    return [self parseLog:str_log executablePath:path];
}

#pragma mark - 取特定的部件，适用于一个crash的文件
+ (NSString*)getArchFromSingleLog:(NSString*)log
{
    NSString* str_line = [NSString getFirstPartInString:log expression:PATTERN_ARCHITECTURE];
    NSString* str_result = [[str_line componentsSeparatedByString:@" "] lastObject];
    return str_result;
}

+ (NSString*)getSlideFromSingleLog:(NSString*)log
{
    NSString* str_line = [NSString getFirstPartInString:log expression:PATTERN_SLIDEADDRESS];
    NSString* str_result = [[str_line componentsSeparatedByString:@" "] lastObject];
    return str_result;
}

+ (NSString*)getBaseFromSingleLog:(NSString*)log
{
    NSString* str_line = [NSString getFirstPartInString:log expression:PATTERN_BASEADDRESS];
    NSString* str_result = [[str_line componentsSeparatedByString:@" "] lastObject];
    return str_result;
}

/**
 *  get UUID from a log from umeng
 *
 *  @param log file info
 *
 *  @return UUID
 */
+ (NSString*)getUUIDFromSingleLog:(NSString*)log
{
    NSString* str_line = [NSString getFirstPartInString:log expression:PATTERN_UUID_UMENG];
    NSString* str_result = [[str_line componentsSeparatedByString:@" "] lastObject];
    return str_result;
}

/**
 *  get uuid from an executable file
 *
 *  @param executablePath uuid path
 *
 *  @return uuid of the executable
 */
+ (NSString*)getUUIDFromExecutablePath:(NSString*)executablePath forArchitecture:(NSString *)architecture
{
    if (![NSString isValidString:architecture])
    {
        return nil;
    }
    NSString* str_parseResult = [TaskHelper getResultFromTaskWithPath:@"/usr/bin/dwarfdump" arguments:@[@"-u", executablePath]];
    NSArray* arr_lines = [str_parseResult componentsSeparatedByString:@"\n"];
    
    __block NSString* str_result = nil;
    [arr_lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* str_line = obj;
        if (NSNotFound != [str_line rangeOfString:architecture].location)
        {
            str_result = [NSString getFirstPartInString:str_line expression:PATTERN_UUID];
        }
    }];
    
    return str_result;
}

#pragma mark - csv解析
/**
 *  读取csv信息，然后解析
 *
 *  @param csvPath csv路径
 *  @param path    执行文件路径
 *
 *  @return 解析出来的信息,每一个元素都是一个crash得到的结果
 */
+ (NSArray*)parseLogFromCSVPath:(NSString*)csvPath executablePath:(NSString*)path
{
    NSLog(@"开始...");
    parser = [CSVSymbolizerParser new];
    //读取文件
    //解析csv
    NSLog(@"解析csv...");
    NSArray* arr_csv = [CSVParser parseFile:csvPath];
    if (!arr_csv)
    {
        [AlertHelper showAlertWithTitle:@"Cannot parse csv file" message:nil];
        return nil;
    }
    NSLog(@"解析csv完毕...");
    
    //symbolize每一个report
    NSMutableArray* arr_symbolizedReports = [NSMutableArray array];
    for (NSInteger i = 0; i < arr_csv.count; i++)
    {
        NSDictionary* dic_log = [arr_csv objectAtIndex:i];
        NSLog(@"正在处理第%ld条数据", (long)i);
        NSString* str_symbolizedReport = [parser symbolizeFromInfo:dic_log dsymPath:path];
        if (str_symbolizedReport)
        {
            [arr_symbolizedReports addObject:str_symbolizedReport];
        }
        NSLog(@"第%ld条数据处理完毕", (long)i);
        NSLog(@"result:%@", str_symbolizedReport);
    }
    return arr_symbolizedReports;
}

+ (void)parseLogFromCSVPath:(NSString*)csvPath executablePath:(NSString*)path processBlock:(parseMessageBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
//        NSLog(@"开始...");
//        __block BOOL stop = NO;
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"开始..."]);
        });
        
        parser = [CSVSymbolizerParser new];
        //读取文件
        //解析csv
//        NSLog(@"解析csv...");
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"解析csv..."]);
        });
        
        NSArray* arr_csv = [CSVParser parseFile:csvPath];
        if (!arr_csv)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(@[@"Cannot parse csv file"]);
            });
            [AlertHelper showAlertWithTitle:@"Cannot parse csv file" message:nil];
            return;
        }
//        NSLog(@"解析csv完毕...");
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"解析csv完毕..."]);
        });
        
        //symbolize每一个report
        NSMutableArray* arr_symbolizedReports = [NSMutableArray array];
        for (NSInteger i = 0; i < arr_csv.count; i++)
        {
            NSDictionary* dic_log = [arr_csv objectAtIndex:i];
//            NSLog(@"正在处理第%ld条数据", (long)i);
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(@[[NSString stringWithFormat:@"正在处理第%ld条数据", (long)i]]);
            });
            NSString* str_symbolizedReport = [parser symbolizeFromInfo:dic_log dsymPath:path];
            if (str_symbolizedReport)
            {
                [arr_symbolizedReports addObject:str_symbolizedReport];
            }
//            NSLog(@"第%ld条数据处理完毕", (long)i);
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(@[[NSString stringWithFormat:@"第%ld条数据处理完毕", (long)i]]);
            });
//            NSLog(@"result:%@", str_symbolizedReport);
            dispatch_sync(dispatch_get_main_queue(), ^{
                block([str_symbolizedReport componentsSeparatedByString:@"\n"]);
            });
        }
    });
}

#pragma mark - 解析真机崩溃
+ (NSString*)parseDeviceLog:(NSString*)crashLogPath executablePath:(NSString*)path
{
    parser = [DeviceCrashReportParser new];
    NSString* str_info = [NSString getLogFileWithPath:crashLogPath];
    NSString* str_result = [parser symbolizeFromInfo:str_info dsymPath:path];
    return str_result;
}

/**
 *  读取真机崩溃信息，然后解析
 *
 *  @param crashLogPath 真机崩溃日志的地址
 *  @param path     执行文件路径
 *  @param block    回调的block
 *
 *  @return 解析出来的信息
 */
+ (void)parseDeviceLog:(NSString*)crashLogPath executablePath:(NSString*)path processBlock:(parseMessageBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"开始..."]);
        });
        
        parser = [DeviceCrashReportParser new];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"读取日志信息..."]);
        });
        NSString* str_info = [NSString getLogFileWithPath:crashLogPath];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"读取日志信息完毕..."]);
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"开始解析..."]);
        });
        NSString* str_result = [parser symbolizeFromInfo:str_info dsymPath:path];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(@[@"解析完毕..."]);
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            block([str_result componentsSeparatedByString:@"\n"]);
        });
    });
}
@end
