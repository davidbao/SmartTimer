//
//  SelectTaskTableViewController.m
//  SmartTimer
//
//  Created by baowei on 14-3-6.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "SelectTaskTableViewController.h"
#import "TimeChartViewController.h"

#include "PlanService.h"

#define MAX_SELECTEDTASKS_COUNT 16

static NSPlan* editPlan = nil;

@interface SelectTaskTableViewController ()

@end

@implementation SelectTaskTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allTasks = [NSMutableArray arrayWithObjects:nil];
    self.selectedTasks = [NSMutableArray arrayWithObjects:nil];
    
    [self initTableViewData];
    
    for (int i=0; i<MIN([self.allTasks count], MAX_SELECTEDTASKS_COUNT); i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell){
            NSTask *currentTask = self.allTasks[i];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selectedTasks addObject:currentTask];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)setCurrentPlan:(NSPlan*) plan {
    editPlan = plan;
}

- (IBAction)ReturnAction:(id)sender {
    editPlan = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.allTasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCell";
    
    NSTask *currentTask = [self.allTasks objectAtIndex:indexPath.row];
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
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell) {
        NSTask *currentTask = [self.allTasks objectAtIndex:indexPath.row];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selectedTasks addObject:currentTask];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedTasks removeObject:currentTask];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)initTableViewData {
    [self.allTasks removeAllObjects];
    
    PlanService* pservice = Singleton<PlanService>::instance();
    const Tasks* tasks = pservice->getTasks(editPlan.planId);
    for(int i=0;i<tasks->count();i++)
    {
        const Task* task = tasks->at(i);
        NSTask *nstask = [[NSTask alloc] initWithPlan:editPlan task:task];
        
        [self.allTasks addObject:nstask];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initTableViewData];
    
    [self.selectedTasks removeAllObjects];
    
    for (int i=0; i<[self.allTasks count]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell){
            NSTask *currentTask = self.allTasks[i];
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                [self.selectedTasks addObject:currentTask];
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"statTasksSegue"]) {
        [TimeChartViewController setSelectedTasks:self.selectedTasks];
    }
}

@end
