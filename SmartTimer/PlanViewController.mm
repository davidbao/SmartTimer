//
//  ViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-19.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "PlanViewController.h"
#import "AddPlanViewController.h"
#import "PlanDetailViewController.h"
#include "Common/Singleton.h"
#include "PlanService.h"

#import "NSPlan.h"

@interface PlanViewController ()

@end

@implementation PlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.plans = [NSMutableArray arrayWithObjects:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.plans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlanCell";
    
    NSPlan *currentPlan = [self.plans objectAtIndex:indexPath.row];
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
                        label.text = [currentPlan getNameStr];
                        break;
                    case 2:
                        label.text = [currentPlan getIntervalStr];
                        break;
                    case 3:
                        label.text = [currentPlan getCurrentTimeStr];
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
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSPlan *currentPlan = [self.plans objectAtIndex:indexPath.row];
    [PlanDetailViewController setCurrentPlan:currentPlan];
    
    PlanDetailViewController *detailViewController = [self.storyboard
                                                      instantiateViewControllerWithIdentifier:@"PlanDetailViewController"];
//    UITabBarController *tab = [[UITabBarController alloc]
//                               initWithRootViewController:detailViewController];
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:detailViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

//- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation: (UITableViewRowAnimation)animation{
//    
//}
//- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation: (UITableViewRowAnimation)animation{
//    
//}
//- (NSString *)tableView:(UITableView *)tableView
//                        titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return @"delete";
//}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove the plan from service.
        NSPlan* nsplan = [self.plans objectAtIndex:indexPath.row];
        assert(nsplan);
        Plan plan;
        [nsplan toPlan:plan];
        PlanService* pservice = Singleton<PlanService>::instance();
        pservice->deletePlan(plan);
        
        [self.plans removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.plans removeAllObjects];
    
    PlanService* pservice = Singleton<PlanService>::instance();
    const Plans* plans = pservice->getPlans();
    for(int i=0;i<plans->count();i++)
    {
        const Plan* plan = plans->at(i);
        NSPlan *nsplan = [[NSPlan alloc] initWithPlan:plan];
        
        [self.plans addObject:nsplan];
    }
    
    [self.tableView reloadData];
}

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:self.tableView.editing == NO ? YES : NO animated:YES];
}

@end
