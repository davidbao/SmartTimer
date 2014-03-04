//
//  NSMessageBox.h
//  SmartTimer
//
//  Created by baowei on 14-3-4.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMessageBox : NSObject

+ (void) show:(NSString*) title buttonTitle:(NSString*)buttonTitle info:(NSString*)str;

@end
