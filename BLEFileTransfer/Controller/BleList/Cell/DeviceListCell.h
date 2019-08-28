//
//  DeviceListCell.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 25/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceListCell : UITableViewCell
@property (strong,nonatomic) UILabel *deviceName;
@property (strong,nonatomic) UILabel *deviceID;
@property (strong,nonatomic) UILabel *rssi;



@end

NS_ASSUME_NONNULL_END
