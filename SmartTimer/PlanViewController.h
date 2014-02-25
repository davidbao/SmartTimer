//
//  ViewController.h
//  SmartTimer
//
//  Created by baowei on 14-2-19.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Models/Plan.h"
#import <CoreBluetooth/CoreBluetooth.h>
//#include "sqlite3.h"

@class BlueShield;

@interface PlanViewController : UITableViewController

@property (nonatomic, weak) BlueShield *shield;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSMutableArray *plans;

@end
