//
//  BluetoothConnectionController.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 20/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothConnectionController : UIViewController

@property (strong,nonatomic) UIStackView *stackView;
@property (strong,nonatomic) UIButton *ServerButton;
@property (strong,nonatomic) UIButton *ClientButton;


@end

NS_ASSUME_NONNULL_END

