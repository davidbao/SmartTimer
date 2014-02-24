//
//  main.m
//  SmartTimer
//
//  Created by baowei on 14-2-19.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#include "Common/Singleton.h"
#include "PlanService.h"
#include "StorageService.h"

using namespace Common;

int main(int argc, char * argv[])
{
    @autoreleasepool {
        Singleton<Storage::StorageService>::initialize();

        NSString* resPath = [[NSBundle mainBundle] pathForResource:@"smartTimer"
                                                         ofType:@"sql"];
        NSString* content = [NSString stringWithContentsOfFile:resPath
                                                         encoding:NSUTF8StringEncoding
                                                         error:NULL];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        Singleton<Storage::StorageService>::instance()->initDbInfo([documentsDirectory UTF8String], [content UTF8String]);
        Singleton<PlanService>::initialize();
        
        int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));

        Singleton<PlanService>::unInitialize();
        Singleton<Storage::StorageService>::unInitialize();
        
        return result;
    }
}
