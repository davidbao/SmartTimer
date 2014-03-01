//
//  AddPlanViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-20.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "AddPlanViewController.h"
#include "Common/Singleton.h"
#include "PlanService.h"

@interface AddPlanViewController ()

@end

@implementation AddPlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)AddPlan:(UIBarButtonItem *)sender {
    string name = [_planName.text UTF8String];
    time_t interval = _planInterval.countDownDuration;  // unit: sec
    time_t now = [[NSDate date] timeIntervalSince1970];

    Plan plan(name, interval, now);
    PlanService* pservice = Singleton<PlanService>::instance();
    pservice->addPlan(plan);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
