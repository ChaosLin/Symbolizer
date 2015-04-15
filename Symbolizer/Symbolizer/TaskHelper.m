//
//  TaskHelper.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/4/3.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "TaskHelper.h"
#import "NSString+Utility.h"

@implementation TaskHelper

+ (void)runTaskWithPath:(NSString*)path arguments:(NSArray*)arguments
{
    if ([NSString isValidString:path] && [arguments isKindOfClass:[NSArray class]])
    {
        NSTask* task = [NSTask new];
        task.launchPath = path;
        task.arguments = arguments;
        [task launch];
        [task waitUntilExit];
    }
}

+ (NSString*)getResultFromTaskWithPath:(NSString*)path arguments:(NSArray*)arguments
{
    if ([NSString isValidString:path] && [arguments isKindOfClass:[NSArray class]])
    {
        NSTask* task = [NSTask new];
        task.launchPath = path;
        task.arguments = arguments;
        NSPipe* pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        NSFileHandle* fileHandler = [pipe fileHandleForReading];
        [task launch];
        [task waitUntilExit];
        
        NSData* data = [fileHandler readDataToEndOfFile];
        NSString* str_result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return str_result;
    }
    return nil;
}
@end
