//
//  AlertHelper.m
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/30.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import "AlertHelper.h"

@implementation AlertHelper

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert* alert = [NSAlert new];
        if (title)
        {
            alert.messageText = title;
        }
        if (message)
        {
            alert.informativeText = message;
        }
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    });
}
@end
