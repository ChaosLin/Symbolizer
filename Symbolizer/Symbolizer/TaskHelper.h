//
//  TaskHelper.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/4/3.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskHelper : NSObject
+ (void)runTaskWithPath:(NSString*)path arguments:(NSArray*)arguments;
+ (NSString*)getResultFromTaskWithPath:(NSString*)path arguments:(NSArray*)arguments;
@end
