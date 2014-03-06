//
//  SelectTaskTableViewController.h
//  SmartTimer
//
//  Created by baowei on 14-3-6.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSPlan.h"

@interface SelectTaskTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tasks;

+ (void)setCurrentPlan:(NSPlan*) plan;

@end
