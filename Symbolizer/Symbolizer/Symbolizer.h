//
//  Symbolizer.h
//  test_address
//
//  Created by RentonTheUncoped on 15/3/17.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void(^parseMessageBlock)(NSArray* messages, BOOL* shouldStop);
typedef void(^parseMessageBlock)(NSArray* messages);

@interface Symbolizer : NSObject

/**
 *  符号化，适用于Umeng csv里面的地址
 *
 *  @param arch    结构
 *  @param path    包的地址
 *  @param address 计算出来的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseInfoWithArchitechture:(NSString*)arch filePath:(NSString*)path address:(NSInteger)address;

/**
 *  符号化，适用于UMeng web端单个的报告
 *
 *  @param arch          结构
 *  @param path          包的地址
 *  @param address_slide slide地址
 *  @param address_base  base地址
 *  @param address_stack 栈的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseInfoWithArchitechture:(NSString*)arch filePath:(NSString*)path slideAddress:(NSInteger)address_slide baseAddress:(NSInteger)address_base stackAddress:(NSInteger)address_stack;

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
+ (NSString*)parseInfoWithArchitechture:(NSString *)arch filePath:(NSString *)path baseAddress:(NSInteger)address_base stackAddress:(NSInteger)address_stack;

/**
 *  从单一的日志文件符号化,格式为Umeng一个日志信息，不适用于csv
 *
 *  @param logFilePath 日志文件路径
 *  @param path        包的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseLogFile:(NSString*)logFilePath executablePath:(NSString*)path;

/**
 *  从日志信息里面符号化，格式为Umeng一个日志信息，不适用于csv
 *
 *  @param log  日志信息
 *  @param path 包的地址
 *
 *  @return 符号化出来的数据
 */
+ (NSString*)parseLog:(NSString*)log executablePath:(NSString*)path;

/**
 *  读取csv信息，然后解析,注意CSV每一行的堆栈的地址是处理过后正确的地址，不需要再进行偏移
 *
 *  @param csvPath csv路径
 *  @param path    执行文件路径
 *
 *  @return 解析出来的信息,每一个元素都是一个crash得到的结果
 */
+ (NSArray*)parseLogFromCSVPath:(NSString*)csvPath executablePath:(NSString*)path;

/**
 *  读取csv信息，然后解析,注意CSV每一行的堆栈的地址是处理过后正确的地址，不需要再进行偏移
 *
 *  @param csvPath csv路径
 *  @param path    执行文件路径
 *  @param block    进度回度block
 *  @return
 */
+ (void)parseLogFromCSVPath:(NSString*)csvPath executablePath:(NSString*)path processBlock:(parseMessageBlock)block;

/**
 *  读取真机崩溃信息，然后解析
 *
 *  @param crashLogPath 真机崩溃日志的地址
 *  @param path    执行文件路径
 *
 *  @return 解析出来的信息
 */
+ (NSString*)parseDeviceLog:(NSString*)crashLogPath executablePath:(NSString*)path;


/**
 *  读取真机崩溃信息，然后解析
 *
 *  @param crashLogPath 真机崩溃日志的地址
 *  @param path     执行文件路径
 *  @param block    回调的block
 *
 *  @return 解析出来的信息
 */
+ (void)parseDeviceLog:(NSString*)crashLogPath executablePath:(NSString*)path processBlock:(parseMessageBlock)block;

/**
 *  get UUID from a log from umeng
 *
 *  @param log file info
 *
 *  @return UUID
 */
+ (NSString*)getUUIDFromSingleLog:(NSString*)log;

/**
 *  get uuid from an executable file
 *
 *  @param executablePath uuid path
 *  @param architecture architecture specified,eg:armv7,armv7s,arm64
 *
 *  @return uuid of the executable
 */
+ (NSString*)getUUIDFromExecutablePath:(NSString*)executablePath forArchitecture:(NSString*)architecture;
@end
