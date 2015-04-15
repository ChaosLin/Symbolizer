//
//  FilePathHelper.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/26.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用来处理一些文件路径上的东西，比如从一个archive里面得到dsym的路径
 */
@interface FilePathHelper : NSObject

/**
 *  从一个archive路径里面得到dsym的路径
 *
 *  @param path archive的路径
 *
 *  @return dsym路径
 */
+ (NSString*)getDsymPathFromArchive:(NSString*)path;
@end
