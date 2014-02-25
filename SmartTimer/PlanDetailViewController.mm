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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCell";
    
    NSTask *currentTask = [self.tasks objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell) {
        UIView* view = cell.contentView;
        assert(view);
        NSArray* labels = view.subviews;
        assert(labels);
        for(int i=0;i<labels.count;i++){
            UILabel* label = [labels objectAtIndex:i];
            if(label){
                switch(label.tag){
                    case 1:
                        label.text = [currentTask getNameStr];
                        break;
                    case 2:
                        label.text = [currentTask getTotalTimeStr];
                        break;
                    case 3:
                        label.text = [currentTask getStartTimeStr];
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    return cell;
}

@end
