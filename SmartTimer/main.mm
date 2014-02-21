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

using namespace Common;

int main(int argc, char * argv[])
{
    @autoreleasepool {
        Singleton<PlanService>::initialize();
        
        int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));

        Singleton<PlanService>::unInitialize();
        return result;
    }
}
