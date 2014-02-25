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

- (IBAction)editPlanAction:(id)sender {
    if(editPlan != nil) {
        NSString* name = self.planName.text;
        NSNumber* interval = [[NSNumber alloc] initWithDouble:self.planInterval.countDownDuration];
        
        if(![editPlan equalTo:name interval:interval]){
            editPlan.name = name;
            editPlan.interval = interval;
            editPlan.currentTime = [NSDate date];
            
            Plan plan;
            [editPlan toPlan:plan];
            PlanService* pservice = Singleton<PlanService>::instance();
            pservice->updatePlan(plan);
        }
    }
    editPlan = nil;
    [self dismissModalViewControllerAnimated:YES];
}

@end
