//
//  AddPlanViewController.h
//  SmartTimer
//
//  Created by baowei on 14-2-20.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Models/Plan.h"

@interface AddPlanViewController : UITableViewController
- (IBAction)AddPlan:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UITextField *planName;
@property (weak, nonatomic) IBOutlet UIDatePicker *planInterval;

- (void) dismissCurrentView;

@end
