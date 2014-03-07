//
//  TaskDetailViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TaskDetailViewController.h"

@interface TaskDetailViewController ()

@end

static NSTask* editTask = nil;

@implementation TaskDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(editTask){
        self.planTime.text      = [editTask getPlanTimeStr];
        self.validTime.text     = [editTask getValidTimeStr];
        self.totalTime.text     = [editTask getTotalTimeStr];
        self.pauseTime.text     = [editTask getPauseTimeStr];
        self.startTime.text     = [editTask getFullStartTimeStr];
        self.stopTime.text      = [editTask getFullStopTimeStr];
        self.pauseCount.text    = [editTask getPauseCountStr];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Done:(id)sender {
    editTask = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)setCurrentTask:(NSTask*) task{
    editTask = task;
}

@end
