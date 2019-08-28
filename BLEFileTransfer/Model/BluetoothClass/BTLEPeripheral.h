//
//  BTLEPeripheral.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 22/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefixHeader.h"


#ifndef LE_Transfer_TransferService_h
#define LE_Transfer_TransferService_h


#endif


NS_ASSUME_NONNULL_BEGIN

@protocol BluetoothPeripheralDelegate
@optional
-(void) receivingCallback:(NSData*)data;
-(void) didCompleteStatus;
-(void) connnectingStatus:(Boolean)status;
-(void) imageReceived:(NSMutableData*)data;
-(void) StartStringMessage:(NSData*)data;
-(void) progressBarCallback:(float)imageProgress;
@end


@interface BTLEPeripheral : NSObject <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) NSTimer       *myTimerName;


@property (strong, nonatomic) CBMutableCharacteristic *charNotify;
@property (strong, nonatomic) CBMutableCharacteristic *charNotifyAndroid;
@property (strong, nonatomic) CBMutableCharacteristic *charWrite;
@property (strong, nonatomic) CBMutableCharacteristic *charRead;
@property (strong, nonatomic) CBMutableCharacteristic *charReceive;
@property (strong, nonatomic) CBMutableCharacteristic *charTextUUID;


@property (nonatomic, retain) NSMutableArray* queue;

@property (strong, nonatomic) CBCentral                 *centralDevice;
@property (strong, nonatomic) id<BluetoothPeripheralDelegate> BleDelegate;
@property (nonatomic) CBPeripheralManagerConnectionLatency nextLatency;


@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;


@property NSInteger NOTIFY_MTU;
@property float completion;
@property Boolean isImageData;

+ (BTLEPeripheral *) sharedInstance;

-(void) initiateDelegatePeripheral;
-(void)stopAdvertising;
-(void)startAdvertising;
-(void)sendImage:(UIImage*)image;
-(void)sendText:(NSString*)textMessage;

@end

NS_ASSUME_NONNULL_END
