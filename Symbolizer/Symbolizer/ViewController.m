//
//  ViewController.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/17.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "ViewController.h"
#import "Symbolizer.h"
#import "FilePathHelper.h"
#import "AlertHelper.h"

@interface ViewController()
@property (nonatomic, strong) NSMutableArray* arr_symbols;
@property (nonatomic, assign) BOOL shouldAutoScrollToLast;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [Symbolizer parseInfoWithArchitechture:@"armv7" filePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/当当" address:0x4493ad];
//    [Symbolizer parseInfoWithArchitechture:@"armv7" filePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/当当"  slideAddress:0x00004000 baseAddress:0x0001d000 stackAddress:0x004e9c51];
    
//    NSString* str_csv = [Symbolizer getLogFileWithPath:[[NSBundle mainBundle] pathForResource:@"log" ofType:@"csv"]];
    
//    NSString* result = [Symbolizer parseLogFile:[[NSBundle mainBundle] pathForResource:@"LogFile" ofType:@"text"] executablePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/当当"];
    
//    [FilePathHelper getDsymPathFromArchive:@"/Users/RentonTheUncoped/Downloads/CrashDebug/iphone5.0.2.xcarchive"];
    
    
//    NSArray* result = [Symbolizer parseLogFromCSVPath:@"/Users/RentonTheUncoped/Downloads/Umeng_total_0326.csv" executablePath:@"/Users/RentonTheUncoped/Downloads/CrashDebug/当当"];
//    NSLog(@"%@", result);
    
    self.arr_symbols = [NSMutableArray array];
    
    self.shouldAutoScrollToLast = YES;
    
    
//    NSTimer* timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(addNew) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - TalbeView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.arr_symbols.count;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* str_symbol = [self.arr_symbols objectAtIndex:row];
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // Since this is a single-column table view, this would not be necessary.
    // But it's a good practice to do it in order by remember it when a table is multicolumn.
    if( [tableColumn.identifier isEqualToString:@"Sym"] )
    {
//        cellView.imageView.image = [NSImage imageNamed:@"9284653-1_h.jpg"];
        cellView.textField.stringValue = str_symbol;
        //        [cellView.textField;
        return cellView;
    }
    return cellView;
}

#pragma mark - Action

- (IBAction)chooseCSVPath:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        // Update the path text field
        NSString *path = [[openPanel URL] path];
        self.label_csvPath.stringValue = path;
        self.str_logPath = path;
    }

}

- (IBAction)chooseArchivePath:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    //    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        // Update the path text field
        NSString *path = [[openPanel URL] path];
        self.label_archivePath.stringValue = path;
        self.str_archivePath = path;
    }
}

- (IBAction)symbolize:(id)sender
{
    if (!self.str_archivePath)
    {
        [AlertHelper showAlertWithTitle:@"ArchivePath should not be nil" message:nil];
        return;
    }
    if (![self.str_archivePath hasSuffix:@".xcarchive"])
    {
        [AlertHelper showAlertWithTitle:@"ArchiveFile/CrashFile should be has the extenstion of .xcarchive or .crash" message:nil];
        return;
    }
    if (!self.str_logPath)
    {
        [AlertHelper showAlertWithTitle:@"CSVPath/Log should not be nil" message:nil];
        return;
    }
    if (![self.str_logPath hasSuffix:@".csv"] && ![self.str_logPath hasSuffix:@".crash"])
    {
        [AlertHelper showAlertWithTitle:@"CSVPath/Log should be has the extenstion of .csv or .crash" message:nil];
        return;
    }
    
    [self.arr_symbols removeAllObjects];
    [self.tablView reloadData];
    self.shouldAutoScrollToLast = YES;
    if ([self.str_logPath hasSuffix:@".csv"])
    {
        [Symbolizer parseLogFromCSVPath:self.str_logPath executablePath:[FilePathHelper getDsymPathFromArchive:self.str_archivePath] processBlock:^(NSArray *messages) {
        [self addMessages:messages];
//        *shouldStop = YES;
        }];
    }
    else if ([self.str_logPath hasSuffix:@".crash"])
    {
//        NSString* str_result = [Symbolizer parseDeviceLog:self.str_logPath executablePath:[FilePathHelper getDsymPathFromArchive:self.str_archivePath]];
//        NSArray* arr_lines = [str_result componentsSeparatedByString:@"\n"];
//        [self.arr_symbols addObjectsFromArray:arr_lines];
//        [self.tablView reloadData];
        [Symbolizer parseDeviceLog:self.str_logPath executablePath:[FilePathHelper getDsymPathFromArchive:self.str_archivePath] processBlock:^(NSArray *messages) {
            [self addMessages:messages];
            [self.tablView reloadData];
        }];
    }
}


#pragma mark - NSTableView动画效果
- (void)addMessages:(NSArray*)messages
{
    if ([messages isKindOfClass:[NSArray class]])
    {
//        [self.tablView beginUpdates];
        [self.arr_symbols addObjectsFromArray:messages];
//        NSRange range;
//        range.location = self.arr_symbols.count - messages.count - 1;
//        range.length = messages.count;
//        NSIndexSet* set_range = [NSIndexSet indexSetWithIndexesInRange:range];
//        [self.tablView insertRowsAtIndexes:set_range withAnimation:NSTableViewAnimationSlideUp];
//        [self.tablView endUpdates];
        [self.tablView reloadData];
        NSInteger lastRow = self.arr_symbols.count - 1;
        if (0 < lastRow)
        {
            if (self.shouldAutoScrollToLast)
            {
//                [self.tablView scrollRowToVisible:lastRow];
            }
        }
    }
}

- (void)addNew
{
    [self addMessages:@[@"4", @"5", @"6", @"7"]];
}
@end
