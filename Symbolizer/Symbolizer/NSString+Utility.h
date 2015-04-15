//
//  NSString+Utility.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utility)

/**
 *  从一个字符串里面找到第一次出现的某个字符串
 *
 *  @param string     源字符串
 *  @param expression 正则表达式
 *
 *  @return 第一次找到的字符串
 */
+ (NSString*)getFirstPartInString:(NSString*)string expression:(NSString*)expression;

/**
 *  从16进制的字符串中取得数据
 *
 *  @param string 源字符串
 *
 *  @return 10进制数
 */
+ (unsigned long long)getIntFromHexString:(NSString*)string;

/**
 *  从文件读取信息
 *
 *  @param path 文件路径
 *
 *  @return 文件信息
 */
+ (NSString*)getLogFileWithPath:(NSString*)path;

/**
 *  判断一个字符串是否valid
 *
 *  @param string 要判断的字符串
 *
 *  @return Yes if not nil and isKindOfClass NSString and 0 < length
 */
+ (BOOL)isValidString:(NSString*)string;
@end
