//
//  ViewController.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/17.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField* label_csvPath;
@property (nonatomic, weak) IBOutlet NSTextField* label_archivePath;
@property (nonatomic, weak) IBOutlet NSTableView* tablView;

@property (nonatomic, copy) NSString* str_logPath;
@property (nonatomic, copy) NSString* str_archivePath;

- (IBAction)chooseCSVPath:(id)sender;
- (IBAction)chooseArchivePath:(id)sender;
- (IBAction)symbolize:(id)sender;
@end

