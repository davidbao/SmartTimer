//
//  TaskDetailViewController.h
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSTask.h"

@interface TaskDetailViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *totalTime;
@property (weak, nonatomic) IBOutlet UITextField *pauseTime;
@property (weak, nonatomic) IBOutlet UITextField *startTime;
@property (weak, nonatomic) IBOutlet UITextField *stopTime;
@property (weak, nonatomic) IBOutlet UITextField *pauseCount;

+ (void)setCurrentTask:(NSTask*) task;

@end
