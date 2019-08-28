//
//  DescriptionViewController.h
//  BLEFileTransfer
//
//  Created by Anil Kumar on 19/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface DescriptionViewController : UIViewController

@property (nonatomic,retain) UIActivityIndicatorView *IndicatorView;
@property (strong,nonatomic) UIButton *imagePickerBtn;
@property (strong,nonatomic) UIImageView *imageview;
@property (strong,nonatomic) UIButton *sendImageBtn;
@property (strong,nonatomic) UIImage *pickerImage;
@property (strong,nonatomic) UILabel *connectedLabel;
@property (nonatomic,retain) UIProgressView *progressview;
@property (strong,nonatomic) UILabel *time_date;

@end

NS_ASSUME_NONNULL_END
