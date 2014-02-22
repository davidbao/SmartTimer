//
//  ViewController.m
//  SmartTimer
//
//  Created by baowei on 14-2-19.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "PlanViewController.h"
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
        cell.textLabel.text = currentPlan.name;
        cell.detailTextLabel.text = [currentPlan getInternalStr];
    }
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)viewWillAppear:(BOOL)animated
{
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
    
    [self.tableView reloadData];}
@end
