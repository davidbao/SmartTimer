//
//  PlanDetailViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "PlanDetailViewController.h"
#include "PlanService.h"

@interface PlanDetailViewController ()

@end

static NSPlan* editPlan = nil;

@implementation PlanDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(editPlan != nil) {
        self.navigationItem.title = editPlan.name;
        self.planName.text = editPlan.name;
        self.planInterval.countDownDuration = [editPlan.interval doubleValue];
    }
}

- (void)viewDidUnload{
    editPlan = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)setCurrentPlan:(NSPlan*) plan{
    editPlan = plan;
}

- (IBAction)editPlan:(id)sender {
    if(editPlan != nil) {
        editPlan.name = self.planName.text;
        editPlan.interval = [[NSNumber alloc] initWithDouble:self.planInterval.countDownDuration];
        editPlan.currentTime = [NSDate date];
        
        string name = [self.planName.text UTF8String];
        time_t interval = _planInterval.countDownDuration;  // unit: sec
        time_t now = [editPlan.currentTime timeIntervalSince1970];
        PlanService* pservice = Singleton<PlanService>::instance();
        pservice->editPlan(editPlan.planId, name, interval, now);
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
