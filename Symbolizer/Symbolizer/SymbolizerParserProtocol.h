//
//  SymbolizerParser.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SymbolizerParserProtocol <NSObject>
/**
 *  取结构
 *
 *  @param info 数据
 *
 *  @return 结构
 */
- (NSString*)getArchitectureFromInfo:(id)info;

//+ (NSString*)getStackAddressFromInfo:(id)info;

/**
 *  取Base地址
 *
 *  @param info 数据
 *
 *  @return Base地址
 */
- (NSString*)getBaseAddressFromInfo:(id)info;

/**
 *  取Slide地址
 *
 *  @param info 数据
 *
 *  @return Slide地址
 */
- (NSString*)getSlideAddressFromInfo:(id)info;

/**
 *  取UUID
 *
 *  @param info 数据
 *
 *  @return UUID
 */
- (NSString*)getUUIDFromInfo:(id)info;

/**
 *  从数据中解析
 *
 *  @param info 数据
 *
 *  @return 解析完的结果
 */
- (NSString*)symbolizeFromInfo:(id)info dsymPath:(NSString*)path;

@optional
- (NSArray*)getStackInfoFromInfo:(id)info;
- (NSString*)getStackAddressFormLine:(NSString*)lineString;
- (BOOL)checkInfo:(id)info;
@end
