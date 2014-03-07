//
//  TaskViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-26.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TaskViewController.h"
#import "NSTask.h"
#import "TaskDetailViewController.h"
#import "SearchViewController.h"
#include "PlanService.h"

@interface TaskViewController ()

@end

static NSPlan* editPlan = nil;

@implementation TaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tasks = [NSMutableArray arrayWithObjects:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)setCurrentPlan:(NSPlan*) plan{
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
    return [self.tasks count];
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
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSTask *currentTask = [self.tasks objectAtIndex:indexPath.row];
    [TaskDetailViewController setCurrentTask:currentTask];
    
    TaskDetailViewController *detailController = [self.storyboard
                                         instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:detailController];
    [self presentViewController:nav animated:YES completion:nil];
    
//    [self performSegueWithIdentifier:@"shieldSegue" sender:currentTask];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tasks removeAllObjects];
    
    PlanService* pservice = Singleton<PlanService>::instance();
    const Tasks* tasks = pservice->getTasks(editPlan.planId);
    for(int i=0;i<tasks->count();i++)
    {
        const Task* task = tasks->at(i);
        NSTask *nstask = [[NSTask alloc] initWithPlan:editPlan task:task];
        
        [self.tasks addObject:nstask];
    }
    
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"syncTasksSegue"]) {
        UINavigationController* nav = (UINavigationController*)segue.destinationViewController;
        SearchViewController *searchController = (SearchViewController *)nav.topViewController;
        searchController.syncType = SyncTask;
        searchController.planId = editPlan != nil ? editPlan.planId : 0;
    }
}

@end
