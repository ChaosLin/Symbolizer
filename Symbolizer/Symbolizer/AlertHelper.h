//
//  AlertHelper.h
//  Symbolizer
//
//  Created by RentonTheUncoped on 15/3/30.
//  Copyright (c) 2015年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AlertHelper : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
@end
