//
//  SearchViewController.h
//  SmartTimer
//
//  Created by baowei on 14-3-1.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SyncNone = 0,
    SyncPlan = 1,
    SyncTask = 2,
}SyncTypes;

@interface SearchViewController : UITableViewController

@property (nonatomic) SyncTypes syncType;
@property (nonatomic) NSInteger planId;

@end
