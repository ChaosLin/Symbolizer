//
//  CSVParser.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/25.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVParser : NSObject

+ (NSArray*)parseDataInfo:(NSString*)info;
+ (NSArray*)parseLineFromInfo:(NSString*)info;
+ (NSArray*)parseFile:(NSString*)filePath;
@end
