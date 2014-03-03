//
//  NSDeviceService.m
//  SmartTimer
//
//  Created by baowei on 14-3-1.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSDeviceService.h"
#import "BlueShield.h"
#import "BSDefines.h"
#import "MBProgressHUD.h"
#import "NSTask.h"
#include "common/BCDUtilities.h"
#include "common/Array.h"
#include "common/ByteArray.h"
#include "common/MemoryStream.h"
#include "common/Crc16Utilities.h"
#include "PlanService.h"
#include "common/Thread.h"

using namespace Common;

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

const int Header = 0xEE;
const int Tail = 0xEF;

static int _frameId = 0;

static bool _connected = false;
static bool _retrivedTasks = false;
static byte _tasksBuffer[512];
static int _tasksBufferCount = 0;
static NSObject *_tasksLocker = [[NSObject alloc] init];

@interface NSDeviceService()
@property (copy, nonatomic) SyncSuccessBlock syncPlansOnBlock;
@property (copy, nonatomic) SyncSuccessBlock syncTasksOnBlock;
@property (nonatomic) BOOL syncTimeSuccess;
@property (nonatomic) BOOL syncPlansSuccess;
@property (nonatomic) BOOL syncTasksSuccess;
@end

@implementation NSDeviceService

+ (id)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init{
    self = [super init];
    
    if (self)
    {
        _shield = [[BlueShield alloc] init];
    }
    
    return self;
}

- (void)didSyncPlansOnBlock:(SyncSuccessBlock)block {
    _syncPlansOnBlock = block;
}
- (void)didSyncTasksOnBlock:(SyncSuccessBlock)block {
    _syncTasksOnBlock = block;
}

- (void)connectShield:(CBPeripheral*)p{
    self.peripheral = p;
    _connected = false;
    
    [_shield connectPeripheral:_peripheral];
    
    [_shield didDiscoverCharacteristicsBlock:^(id response, NSError *error) {
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_shield notification:[CBUUID UUIDWithString:BS_SERIAL_SERVICE_UUID]
               characteristicUUID:[CBUUID UUIDWithString:BS_SERIAL_RX_UUID]
                                p:_peripheral
                               on:YES];
            
            _connected = true;
            
            [_shield didUpdateValueBlock:^(NSData *data, NSError *error) {
                byte* buffer = (byte*)[data bytes];
                int length = [data length];
                ByteArray array(buffer, length);
#if DEBUG
                NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
                [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                NSString* timeStr = [DateFormatter stringFromDate:[NSDate date]];
                printf("time: %s, recv buffer: %s\n", [timeStr UTF8String], array.toString().data());
#endif
               
                [self processReceiveBuffer:data];
            }];
        });
    }];
}

- (void) msbox:(NSString*) title buttonTitle:(NSString*)buttonTitle info:(NSString*)str{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                        message:str
                                                        delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(buttonTitle, nil)
                                                        otherButtonTitles:nil];
    [errorAlert show];
    
}

- (void)controlSetup:(UITableView*)tableView{
    [_shield controlSetup];
    
    [_shield didPowerOnBlock:^(id response, NSError *error) {
        [self refresh:tableView];
    }];
}

- (void)refresh:(UITableView*)tableView{
    double timeout = 3;
    [MBProgressHUD showHUDAddedTo:tableView animated:YES];
    [_shield findBLEPeripherals:timeout];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:tableView animated:YES];
    });
}

- (void)syncPlans:(CBPeripheral*)p parentViewController:(UITableViewController*)parent{
    double timeout = 3;
    [MBProgressHUD showHUDAddedTo:parent.tableView animated:YES];
    
    // connect shield.
    [self connectShield:p];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // sync time.
        [self syncTime];
        Thread::msleep(100);
        // download plans.
        [self download];
    
        [MBProgressHUD hideAllHUDsForView:parent.tableView animated:YES];
        
        // messagebox something.
        // self.syncTimeSuccess
        // self.syncPlansSuccess
        NSString* sstr = NSLocalizedString(@"Success", nil);
        NSString* fstr = NSLocalizedString(@"Failed", nil);
        [self msbox:NSLocalizedString(@"Information", nil)
                                                    buttonTitle:NSLocalizedString(@"Ok", nil)
                                                    info:[NSString stringWithFormat:NSLocalizedString(@"SyncPlansInfo", nil),
                                                                      self.syncTimeSuccess == YES ? sstr : fstr,
                                                                      self.syncPlansSuccess == YES ? sstr : fstr]];
        
        [parent dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)syncTasks:(CBPeripheral*)p parentViewController:(UITableViewController*)parent{
    double timeout = 3;
    [MBProgressHUD showHUDAddedTo:parent.tableView animated:YES];
    
    // connect shield.
    [self connectShield:p];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // sync time.
        [self syncTime];
        Thread::msleep(100);
        // download plans.
        [self upload];

        [MBProgressHUD hideAllHUDsForView:parent.tableView animated:YES];
        
        // messagebox something.
        // self.syncTimeSuccess
        // self.syncTasksSuccess
        NSString* sstr = NSLocalizedString(@"Success", nil);
        NSString* fstr = NSLocalizedString(@"Failed", nil);
        [self msbox:NSLocalizedString(@"Information", nil)
                                                    buttonTitle:NSLocalizedString(@"Ok", nil)
                                                    info:[NSString stringWithFormat:NSLocalizedString(@"SyncTasksInfo", nil),
                                                                        self.syncTimeSuccess == YES ? sstr : fstr,
                                                                        self.syncTasksSuccess == YES ? sstr : fstr]];
        
        [parent dismissViewControllerAnimated:YES completion:nil];
    });
}

- (Boolean)checkBuffer:(const unsigned char*) buffer
                length:(int) length{
    byte header = buffer[0];
    byte tail = buffer[length-1];
    if(header == Header && tail == Tail){
        ushort expected = Crc16Utilities::CheckByBit(buffer, 0, length-3); // remove cr16 & tail
        byte crcHigh = buffer[length-3];
        byte crcLow = buffer[length-2];
        ushort actual = ((crcHigh << 8) & 0xFF00) + crcLow;
        if(expected == actual){
            return YES;
        }
    }
    return NO;
}

-(void)processReceiveBuffer:(byte*)buffer length:(int)length{
    MemoryStream stream(buffer, length);
    if (length > 8)
    {
        byte header = stream.readByte();
        if(header == Header){
            ushort len = BCDUtilities::BCDToUInt16(buffer+2);
            Boolean check = (len == length - 4 && [self checkBuffer:buffer length:length]) ||
            (len != length - 4);
            if(check){                stream.readByte();               // skip frameId
                stream.readInt16();              // skip length
                byte command = stream.readByte();
                if(command == 0x21){             // sync time.
                    byte status = stream.readByte();
                    self.syncTimeSuccess = status == 0 ? YES : NO;
#if DEBUG
                    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
                    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                    NSString* timeStr = [DateFormatter stringFromDate:[NSDate date]];
                    printf("time: %s, Sync time successfully. status is %d\n", [timeStr UTF8String], status);
#endif
                }
                else if(command == 0x22){        // download.
                    byte status = stream.readByte();
                    self.syncPlansSuccess = status == 0 ? YES : NO;
#if DEBUG
                    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
                    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                    NSString* timeStr = [DateFormatter stringFromDate:[NSDate date]];
                    printf("time: %s, Download the plans successfully. status is %d\n", [timeStr UTF8String], status);
#endif
                }
                else if(command == 0x23){        // retrived the packet count.
                    byte status = stream.readByte();
                    if(status == 0){             // successfully
                        byte packetCount = stream.readByte();
                        for (byte i=0; i<packetCount; i++) {
                            byte buffer[512];
                            memset(buffer, 0, sizeof(buffer));
                            int length = 0;
                            [self makeTasksBuffer:buffer returnLength:&length packetNo:i];
                            
                            [self sendTxBuffer:buffer sendLength:length];
                        }
                    }
                }
                else if(command == 0x24){        // retrived the packet.
                    @synchronized(_tasksLocker){
                        _retrivedTasks = true;
                        _tasksBufferCount = 0;
                        
                        memcpy(&_tasksBuffer[_tasksBufferCount], buffer, length);
                        _tasksBufferCount += length;
                    }
                }
            }
        }
    }
}
- (void)processRetrivedTasks:(byte*)buffer length:(int)length{
    @synchronized(_tasksLocker){
        memcpy(&_tasksBuffer[_tasksBufferCount], buffer, length);
        _tasksBufferCount += length;
        
        if (_tasksBufferCount >= 4) {
            MemoryStream ms(_tasksBuffer + 2, length);
            ushort len = ms.readBCDUInt16();
            if(_tasksBufferCount >= len + 4 &&
               buffer[length-1] == Tail){
                _retrivedTasks = false;
#if DEBUG
                ByteArray array(_tasksBuffer, _tasksBufferCount);
                NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
                [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                NSString* timeStr = [DateFormatter stringFromDate:[NSDate date]];
                printf("time: %s, recv full buffer: %s\n", [timeStr UTF8String], array.toString().data());
#endif
                // process 0x24 command.
                Tasks tasks;
                MemoryStream stream(_tasksBuffer + 5, _tasksBufferCount);
                byte tcount = stream.readBCDByte();
                for(int i=0;i<tcount;i++){
                    Task* task = new Task();
                    //task->PlanId
                    task->Id = stream.readBCDByte();
                    task->StartTime = stream.readBCDDateTime();
                    byte timeCount = stream.readBCDByte();
                    for (int j=0; j<timeCount; j++) {
                        task->addInterval(stream.readBCDTime());
                    }
                    tasks.add(task);
                }
                PlanService* pservice = Singleton<PlanService>::instance();
                pservice->updateTasks(self.planId, tasks);
                
                // send ack.
                byte buffer[512];
                memset(buffer, 0, sizeof(buffer));
                int length = 0;
                [self makeTasksAckBuffer:buffer returnLength:&length];
                
                [self sendTxBuffer:buffer sendLength:length];
                
#if DEBUG
                NSDateFormatter *DateFormatter2=[[NSDateFormatter alloc] init];
                [DateFormatter2 setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                NSString* timeStr2 = [DateFormatter2 stringFromDate:[NSDate date]];
                printf("time: %s, Get the tasks successfully.\n", [timeStr2 UTF8String]);
#endif
            }
        }
    }
}

- (void)processReceiveBuffer:(NSData*)data{
    byte* buffer = (byte*)[data bytes];
    int length = [data length];
    
    if(length > 0){
        if (_retrivedTasks) {
            [self processRetrivedTasks:buffer length:length];
        }
        else{
            [self processReceiveBuffer:buffer length:length];
        }
    }
}

- (void) makeSendBuffer:(unsigned char*) buffer
           returnLength:(int*)length
          commandBuffer:(const unsigned char*)cBuffer
          commandLength:(int)cLength{
    MemoryStream stream;
    
    stream.writeByte(Header);         // header
    stream.writeByte(_frameId++);   // frame
    if(_frameId > 0x3f)
        _frameId = 0;
    stream.writeUInt16(0);          // length
    int position = stream.position();
    
    stream.write(cBuffer, 0, cLength);
    
    int crcPosition = stream.position();
    ushort len = crcPosition - position + 3;
    stream.seek(position - 2);
    stream.writeBCDUInt16(len);
    stream.seek(crcPosition);
    
    stream.copyTo(buffer);
    ushort crc16 = Crc16Utilities::CheckByBit(buffer, 0, stream.length());
    stream.writeUInt16((crc16));
    stream.writeByte(Tail);
    
#if DEBUG
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
    NSString* timeStr = [DateFormatter stringFromDate:[NSDate date]];
    printf("time: %s, send buffer: %s\n", [timeStr UTF8String], stream.buffer()->toString().data());
#endif
    
    stream.copyTo(buffer);
    *length = stream.length();
}

- (void) makeSyncTimeCommandBuffer:(unsigned char*) buffer
                      returnLength:(int*)length{
    MemoryStream stream;
    
    stream.writeByte(0x21);         // command
    stream.writeBCDCurrentTime();
    
    stream.copyTo(buffer);
    *length = stream.length();
}
- (void) makeSyncTimeBuffer:(unsigned char*) buffer
               returnLength:(int*)length{
    byte cBuffer[32];
    memset(cBuffer, 0, sizeof(cBuffer));
    int cLength = 0;
    [self makeSyncTimeCommandBuffer:cBuffer returnLength:&cLength];
    
    [self makeSendBuffer:buffer returnLength:length commandBuffer:cBuffer commandLength:cLength];
}

- (void) makeDownloadCommandBuffer:(unsigned char*) buffer
                      returnLength:(int*)length{
    MemoryStream stream;
    
    stream.writeByte(0x22);         // command

    PlanService* pservice = Singleton<PlanService>::instance();
    const Plans* plans = pservice->getPlans();
    
    stream.writeByte(BCDUtilities::ByteToBCD(plans->count()));
    for(int i=0;i<plans->count();i++){
        const Plan* plan = plans->at(i);
        stream.writeBCDByte(plan->Id);
        byte hour = plan->Interval / 60;
        byte minute = plan->Interval % 60;
        stream.writeBCDByte(hour);
        stream.writeBCDByte(minute);
    }
    
    stream.copyTo(buffer);
    *length = stream.length();
}
- (void) makeDownloadBuffer:(unsigned char*) buffer
               returnLength:(int*)length{
    byte cBuffer[32];
    memset(cBuffer, 0, sizeof(cBuffer));
    int cLength = 0;
    [self makeDownloadCommandBuffer:cBuffer returnLength:&cLength];
    
    [self makeSendBuffer:buffer returnLength:length commandBuffer:cBuffer commandLength:cLength];
}

- (void) makeTaskCountCommandBuffer:(unsigned char*) buffer
                       returnLength:(int*)length{
    MemoryStream stream;
    
    stream.writeByte(0x23);         // command
    
    stream.copyTo(buffer);
    *length = stream.length();
}
- (void) makeTaskCountBuffer:(unsigned char*) buffer
                returnLength:(int*)length{
    byte cBuffer[255];
    memset(cBuffer, 0, sizeof(cBuffer));
    int cLength = 0;
    [self makeTaskCountCommandBuffer:cBuffer returnLength:&cLength];
    
    [self makeSendBuffer:buffer returnLength:length commandBuffer:cBuffer commandLength:cLength];
}
- (void) makeTasksCommandBuffer:(unsigned char*) buffer
                   returnLength:(int*)length
                       packetNo:(int)packetNo{
    MemoryStream stream;
    
    stream.writeByte(0x24);         // command
    stream.writeBCDByte(packetNo);  // packetNo
    
    stream.copyTo(buffer);
    *length = stream.length();
}
- (void) makeTasksBuffer:(unsigned char*) buffer
            returnLength:(int*)length
                packetNo:(int)packetNo{
    byte cBuffer[32];
    memset(cBuffer, 0, sizeof(cBuffer));
    int cLength = 0;
    [self makeTasksCommandBuffer:cBuffer returnLength:&cLength packetNo:packetNo];
    
    [self makeSendBuffer:buffer returnLength:length commandBuffer:cBuffer commandLength:cLength];
}
- (void) makeTasksAckCommandBuffer:(unsigned char*) buffer
                      returnLength:(int*)length{
    MemoryStream stream;
    
    stream.writeByte(0x25);         // command
    byte status = 0;
    stream.writeByte(status);       // status
    
    stream.copyTo(buffer);
    *length = stream.length();
}
- (void) makeTasksAckBuffer:(unsigned char*) buffer
               returnLength:(int*)length{
    byte cBuffer[32];
    memset(cBuffer, 0, sizeof(cBuffer));
    int cLength = 0;
    [self makeTasksAckCommandBuffer:cBuffer returnLength:&cLength];
    
    [self makeSendBuffer:buffer returnLength:length commandBuffer:cBuffer commandLength:cLength];
}

- (void)syncTime{
    self.syncTimeSuccess = NO;
    
    byte buffer[512];
    memset(buffer, 0, sizeof(buffer));
    int length = 0;
    [self makeSyncTimeBuffer:buffer returnLength:&length];
    
    [self sendTxBuffer:buffer sendLength:length];
}
- (void)download{
    self.syncPlansSuccess = NO;
    
    byte buffer[512];
    memset(buffer, 0, sizeof(buffer));
    int length = 0;
    [self makeDownloadBuffer:buffer returnLength:&length];
    
    [self sendTxBuffer:buffer sendLength:length];
}
- (void)upload{
    self.syncTasksSuccess = NO;
    
    byte buffer[512];
    memset(buffer, 0, sizeof(buffer));
    int length = 0;
    [self makeTaskCountBuffer:buffer returnLength:&length];
    
    [self sendTxBuffer:buffer sendLength:length];
}

- (void) sendTxBuffer:(unsigned char*) buffer sendLength:(int)length{
    NSData *data = [[NSData alloc] initWithBytes:buffer length:(uint)length];
    [_shield writeValue:[CBUUID UUIDWithString:BS_SERIAL_SERVICE_UUID]
     characteristicUUID:[CBUUID UUIDWithString:BS_SERIAL_TX_UUID]
                        p:_peripheral
                        data:data];
}

@end