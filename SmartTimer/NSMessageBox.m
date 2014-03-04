//
//  NSMessageBox.m
//  SmartTimer
//
//  Created by baowei on 14-3-4.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSMessageBox.h"

@implementation NSMessageBox

+ (void) show:(NSString*) title buttonTitle:(NSString*)buttonTitle info:(NSString*)str{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                        message:str
                                                        delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(buttonTitle, nil)
                                                        otherButtonTitles:nil];
    [errorAlert show];
}

@end
