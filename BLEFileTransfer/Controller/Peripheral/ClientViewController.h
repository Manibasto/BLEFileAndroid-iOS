//
//  ClientViewController.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 20/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClientViewController : UIViewController

@property (strong,nonatomic) UIImageView *imagview;
@property (strong,nonatomic) UILabel *connectedLabel;
@property (nonatomic,retain) UIActivityIndicatorView *IndicatorView;
@property (nonatomic,retain) UITextView *ShowMessageFeild;

@property (nonatomic,retain) UIButton *sendText;

@property (nonatomic,retain) UIButton *sendImage;
@property (nonatomic,retain) UISwitch *advitiseBtn;

@end

NS_ASSUME_NONNULL_END
