//
//  SearchViewController.m
//  SmartTimer
//
//  Created by baowei on 14-3-1.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "SearchViewController.h"
#import "MBProgressHUD.h"
#import "BlueShield.h"
#import "BSDefines.h"
#import "NSDeviceService.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDeviceService* dservice = [NSDeviceService sharedInstance];
    [dservice controlSetup:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shieldSegue"]) {
//        BSShieldViewController *shieldController = (BSShieldViewController *)segue.destinationViewController;
//        shieldController.peripheral = sender;
//        shieldController.shield = _shield;
    }
    
}

- (IBAction)refreshAction:(id)sender {
    NSDeviceService* dservice = [NSDeviceService sharedInstance];
    [dservice refresh:self.tableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDeviceService* dservice = [NSDeviceService sharedInstance];
    return [dservice.shield.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"shieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDeviceService* dservice = [NSDeviceService sharedInstance];
    CBPeripheral *p = [dservice.shield.peripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSDeviceService* dservice = [NSDeviceService sharedInstance];
    CBPeripheral *p = [dservice.shield.peripherals objectAtIndex:indexPath.row];
    
    // connect shield.
    [dservice syncPlans:p parentView:tableView];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction

@end
