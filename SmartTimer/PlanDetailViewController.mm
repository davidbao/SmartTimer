//
//  PlanDetailViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "PlanDetailViewController.h"
#include "PlanService.h"
#import "NSTask.h"

@interface PlanDetailViewController ()

@end

static NSPlan* editPlan = nil;

@implementation PlanDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // fixed a bug, the date picker show black background if system version less than 6.0.
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version < 7.0){
        CGRect frame = self.planInterval.frame;
        frame.size.height = 216;
        [self.planInterval setFrame:frame];
    }
    
    if(editPlan != nil) {
        self.navigationItem.title = editPlan.name;
        self.planId.text = [NSString stringWithFormat:@"%d", editPlan.planId];
        self.planName.text = editPlan.name;
        [self.enablePlan setOn:[editPlan enabled]];
        if([editPlan enabled]){
            self.planInterval.countDownDuration = [editPlan.interval doubleValue];
        }
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self enablePlanAction:self.enablePlan];
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

-(void)dismissKeyboard
{
    if ([self.planName isFirstResponder]){
        [self.planName resignFirstResponder];
    }
}
- (IBAction)enablePlanAction:(UISwitch *)sender {
    self.planName.enabled = sender.isOn;
    self.planInterval.userInteractionEnabled = sender.isOn;
}

- (IBAction)editPlanAction:(id)sender {
    if(editPlan != nil) {
        NSString* name = self.planName.text;
        NSNumber* interval = [[NSNumber alloc] initWithDouble:self.enablePlan.isOn ? self.planInterval.countDownDuration : 0];
        
        if(![editPlan equalTo:name interval:interval]){
            editPlan.name = name;
            editPlan.interval = interval;
            editPlan.currentTime = [NSDate date];
            // todo: sync tasks.
            
            Plan plan;
            [editPlan toPlan:plan];
            PlanService* pservice = Singleton<PlanService>::instance();
            pservice->updatePlan(plan);
        }
    }
    editPlan = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
