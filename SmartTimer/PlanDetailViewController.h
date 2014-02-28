//
//  PlanDetailViewController.h
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSPlan.h"

@interface PlanDetailViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *planName;
@property (weak, nonatomic) IBOutlet UIDatePicker *planInterval;
@property (weak, nonatomic) IBOutlet UITextField *planId;
@property (weak, nonatomic) IBOutlet UISwitch *enablePlan;

+ (void)setCurrentPlan:(NSPlan*) plan;

@end
