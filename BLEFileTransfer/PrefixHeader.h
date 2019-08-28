//
//  PrefixHeader.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 20/08/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

//AppDelegate
#import "AppDelegate.h"

//OtherClassFiles
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PulsingHaloLayer.h"

//TableViewCell
#import "DeviceListCell.h"

//ViewControllers
#import "BluetoothConnectionController.h"
#import "DescriptionViewController.h"
#import "ShowBluetoothDevicesController.h"
#import "ClientViewController.h"

//BleModel
#import "BTLECentral.h"
#import "BTLEPeripheral.h"


//UUID'S
#define SERVICE_UUID               @"000018f0-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_NOTIFY_UUID @"00002af1-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_WRITE_UUID  @"00002af1-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_READ_UUID   @"00002af1-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_RECEIVE_ID  @"00002af1-0000-1000-8000-00805f9b34fb"

//#define CHARACTERISTIC_SENT_RECEIVE_ID  @"00002aa2-0000-1000-8000-00805f9b34fb"
#define CHARACTERISTIC_SENT_RECEIVE_ID  @"00002af1-0000-1000-8000-00805f9b34fb"



//PulsingHaloLayer
#define kMaxRadius 130
#define kMaxDuration 10

#endif /* PrefixHeader_h */
