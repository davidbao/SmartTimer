//
//  PlanDetailViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "PlanDetailViewController.h"
#import "NSTask.h"
#import "NSMessageBox.h"
#include "PlanService.h"

#define MAX_PLANNAME_LENGTH 8

static NSPlan* editPlan = nil;

@interface PlanDetailViewController ()

@end

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
    self.planInterval.countDownDuration = 1800;
    
    if(editPlan != nil) {
        self.navigationItem.title = editPlan.name;
        self.planId.text = [NSString stringWithFormat:@"%d", editPlan.planId];
        self.planName.text = editPlan.name;
        [self.enablePlan setOn:[editPlan enabled]];
        if([editPlan enabled]){
            self.planInterval.countDownDuration = [editPlan.interval doubleValue];
        }
    }
    
    self.planName.delegate = (id)self;
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    int textLen = strlen([textField.text UTF8String]);
//    int strLen = strlen([string UTF8String]);
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    return newLength <= MAX_PLANNAME_LENGTH;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger length = textField.text.length;
    if(length>MAX_PLANNAME_LENGTH)
    {
        NSString *memo = [textField.text substringWithRange:NSMakeRange(0, MAX_PLANNAME_LENGTH)];
        self.planName.text = memo;
    }
}

- (IBAction)enablePlanAction:(UISwitch *)sender {
    self.planName.enabled = sender.isOn;
    self.planInterval.userInteractionEnabled = sender.isOn;
}

- (IBAction)editPlanAction:(id)sender {
    if(self.enablePlan.isOn){
        if(self.planName.text == nil ||
           self.planName.text.length == 0){
            [NSMessageBox show:NSLocalizedString(@"Error", nil)
                   buttonTitle:NSLocalizedString(@"Ok", nil)
                          info:NSLocalizedString(@"PlanNameCannotBeEmpty", nil)];
            [self.planName becomeFirstResponder];

            return;
        }
    }
    
    if(editPlan != nil) {
        NSString* name = self.planName.text;
        NSNumber* interval = [[NSNumber alloc] initWithDouble:self.enablePlan.isOn ? self.planInterval.countDownDuration : 0];
        
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
