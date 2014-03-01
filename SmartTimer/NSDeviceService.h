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

@interface NSDeviceService : NSObject

@property (nonatomic, strong) BlueShield *shield;
@property (nonatomic, strong) CBPeripheral *peripheral;

+ (id)sharedInstance;

- (void)controlSetup:(UITableView*)tableView;
- (void)refresh:(UITableView*)tableView;

- (void)syncPlans:(CBPeripheral*)p parentView:(UIView*)parent;

- (void)connectShield:(CBPeripheral*)p;
- (void)syncTime;
- (void)download;
- (void)upload;

@end
