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
#import "TaskViewController.h"
#import "NSPlan.h"
#import "SearchViewController.h"

#include "Common/Singleton.h"
#include "PlanService.h"

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
                        label.textColor = [currentPlan enabled] ? nil : [UIColor lightGrayColor];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSPlan *currentPlan = [self.plans objectAtIndex:indexPath.row];
    [PlanDetailViewController setCurrentPlan:currentPlan];
    [TaskViewController setCurrentPlan:currentPlan];

    UITabBarController *tabController = [self.storyboard
                                         instantiateViewControllerWithIdentifier:@"PlanDetailTabBarController"];
    [self presentViewController:tabController animated:YES completion:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"syncPlansSegue"]) {
        UINavigationController* nav = (UINavigationController*)segue.destinationViewController;
        SearchViewController *searchController = (SearchViewController *)nav.topViewController;
        searchController.syncType = SyncPlan;
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // remove the plan from service.
//        NSPlan* nsplan = [self.plans objectAtIndex:indexPath.row];
//        assert(nsplan);
//        Plan plan;
//        [nsplan toPlan:plan];
//        PlanService* pservice = Singleton<PlanService>::instance();
//        pservice->deletePlan(plan);
//        
//        [self.plans removeObjectAtIndex:indexPath.row];
//        // Delete the row from the data source.
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

////点击删除按钮后的回调
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    UIButton* b = (UIButton*)[cell viewWithTag:1];
//    [UIView beginAnimations:@"" context:nil];
//    [UIView animateWithDuration:0.5 animations:^{
//        b.frame = CGRectMake(b.frame.origin.x-15, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
//        
//    }];
//    [UIView commitAnimations];
//}
////将要出现删除按钮时的回调，调整subview的位置
//-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    UIButton* b = (UIButton*)[cell viewWithTag:1];
//    [UIView beginAnimations:@"" context:nil];
//    [UIView animateWithDuration:0.5 animations:^{
//        b.frame = CGRectMake(b.frame.origin.x-15, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
//        
//    }];
//    [UIView commitAnimations];
//}
////删除按钮消失后的回调，用于重新调整subview到原来位置
//-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    UIButton* b = (UIButton*)[cell viewWithTag:1];
//    [UIView beginAnimations:@"" context:nil];
//    [UIView animateWithDuration:0.5 animations:^{
//        b.frame = CGRectMake(b.frame.origin.x+15, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
//        
//    }];
//    [UIView commitAnimations];
//    
//}
//- (IBAction)editAction:(id)sender {
//    self.navigationItem.leftBarButtonItem.title = self.tableView.editing == NO ?
//                                                NSLocalizedString(@"Done", @"") :
//                                                NSLocalizedString(@"Edit", @"");
//    [self.tableView setEditing:self.tableView.editing == NO ? YES : NO animated:YES];
//}

@end
