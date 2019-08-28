//
//  BTLECentral.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 22/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN


#ifndef LE_Transfer_TransferService_h
#define LE_Transfer_TransferService_h


#endif


@protocol BluetoothCentralDelegate
@optional
-(void) didCompleteStatus;
-(void) didComplete: (CBPeripheral*) peripheral withRssi:(NSInteger*) rssiValue;
-(void) connnectingStatus:(Boolean)status;
-(void) progressBarCallback:(float)imageProgress;
-(void) receiveiImage:(NSData*)data;
-(void) receiveiText:(NSString*)string;

@end


@interface BTLECentral : NSObject  <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral          *ConnectingPeripheral;
@property (strong, nonatomic) CBCharacteristic          *characterstics;
@property (strong, nonatomic) CBCharacteristic          *textCharacterstics;




@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property NSInteger NOTIFY_MTU;
@property float completion;
@property Boolean completionFlag;
@property Boolean TextMessageFlag;

@property (strong, nonatomic) id<BluetoothCentralDelegate> BleDelegate;


+ (BTLECentral *) sharedInstance;


-(void) initiateDelegateCentral;
- (void) connect:(CBPeripheral*) peripheral;
-(void)stopScanning;
-(void)sendData:(UIImage *)image;
-(void)sendTextMessage:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
