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

@interface PlanViewController ()

@end

@implementation PlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PlanService* pservice = Singleton<PlanService>::instance();
    const Plans* plans = pservice->getPlans();
    for(int i=0;i<plans->count();i++)
    {
    }
}
@end
