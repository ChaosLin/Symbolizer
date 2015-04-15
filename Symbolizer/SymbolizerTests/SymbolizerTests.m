//
//  SymbolizerTests.m
//  SymbolizerTests
//
//  Created by RentonTheUncoped on 15/3/17.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "CSVParser.h"
#import "NSString+Utility.h"
#import "Symbolizer.h"

@interface SymbolizerTests : XCTestCase

@end

@implementation SymbolizerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCSVParserLine
{
//    NSError* error = nil;
//    NSString* info = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"csvline" ofType:@"text"] encoding:NSUTF8StringEncoding error:&error];
//    NSArray* result = [CSVParser parseLineFromInfo:info];
}

- (void)testCSVParserFile
{
//    NSError* error = nil;
//    NSString* info = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Umeng" ofType:@"csv"] encoding:NSUTF8StringEncoding error:&error];
//    NSArray* result = [CSVParser parseDataInfo:info];
}

- (void)testGetUUIDFromSingleLog
{
    NSString* str_info = [NSString getLogFileWithPath:[[NSBundle mainBundle] pathForResource:@"LogFile" ofType:@"text"]];
    NSString* uuid = [Symbolizer getUUIDFromSingleLog:str_info];
    XCTAssert([uuid isEqualToString:@"94A00A53-3EE0-39AA-B98E-9113A3557DE7"], @"");
}

- (void)testGetUUIDFromExecutable
{
    NSString* uuid_armv7 = [Symbolizer getUUIDFromExecutablePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/64.xcarchive/dSYMs/crashP.app.dSYM/Contents/Resources/DWARF/crashP" forArchitecture:@"armv7"];
    XCTAssert([uuid_armv7 isEqualToString:@"AACF1C62-DA41-32A9-9C3D-72DC1D3B83F9"], @"");
    NSString* uuid_arm64 = [Symbolizer getUUIDFromExecutablePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/64.xcarchive/dSYMs/crashP.app.dSYM/Contents/Resources/DWARF/crashP" forArchitecture:@"arm64"];
    XCTAssert([uuid_arm64 isEqualToString:@"E72100DC-5F3C-3DD6-83E1-EDF74BC164D6"], @"");
    
    NSString* uuid_armv7_new = [Symbolizer getUUIDFromExecutablePath:@"/Users/RentonTheUncoped/Library/Developer/Xcode/Archives/2015-04-03/crashP 15-4-3 下午5.56.xcarchive/dSYMs/crashP.app.dSYM/Contents/Resources/DWARF/crashP" forArchitecture:@"armv7"];
    XCTAssert(![uuid_armv7 isEqualToString:uuid_armv7_new], @"");
}
@end
