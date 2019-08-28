//
//  ViewController.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 19/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

@interface ShowBluetoothDevicesController : UIViewController

@property (strong,nonatomic) NSMutableArray *peripherals;
@property (retain,nonatomic) NSMutableArray *rssiArray;
@property (strong,nonatomic) NSArray *PairedPeripherals;
@property (nonatomic, weak) PulsingHaloLayer *halo;

@property (retain,nonatomic) UITableView *tableview;
@property (strong,nonatomic) UILabel     *noDataLabel;
@property (strong,nonatomic) UIButton    *bottomButton;
@property (strong,nonatomic) UIImageView *scanImage;
@property (strong,nonatomic) UIView      *scanview;
@property (strong,nonatomic) UILabel     *scanningLabel;
@property (retain,nonatomic) UIRefreshControl *refreshControl;
@end

