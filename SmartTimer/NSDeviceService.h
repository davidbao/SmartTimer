//
//  NSDeviceService.h
//  SmartTimer
//
//  Created by baowei on 14-3-1.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BlueShield;

typedef void (^SyncSuccessBlock)(id response, NSError *error);

@interface NSDeviceService : NSObject

@property (nonatomic, strong) BlueShield *shield;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic) NSInteger planId;

+ (id)sharedInstance;

- (void)controlSetup:(UITableView*)tableView;
- (void)refresh:(UITableView*)tableView;

- (void)syncPlans:(CBPeripheral*)p parentViewController:(UITableViewController*)parent;
- (void)syncTasks:(CBPeripheral*)p parentViewController:(UITableViewController*)parent;

- (void)didSyncPlansOnBlock:(SyncSuccessBlock)block;
- (void)didSyncTasksOnBlock:(SyncSuccessBlock)block;

@end
