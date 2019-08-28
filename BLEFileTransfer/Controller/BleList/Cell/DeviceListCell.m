//
//  DeviceListCell.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 25/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "DeviceListCell.h"

@implementation DeviceListCell
@synthesize deviceName, deviceID, rssi;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  deviceName = [[UILabel alloc]initWithFrame: CGRectZero];
  deviceName.translatesAutoresizingMaskIntoConstraints = false;
  deviceName.text = @"";
  deviceName.textAlignment = NSTextAlignmentLeft;
  deviceName.textColor = UIColor.blackColor;
  [self addSubview:deviceName];
  
  rssi = [[UILabel alloc]initWithFrame: CGRectZero];
  rssi.translatesAutoresizingMaskIntoConstraints = false;
  rssi.text = @"";
  [self addSubview:rssi];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceName attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceName attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceName attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rssi attribute:NSLayoutAttributeRight multiplier:1.0 constant:5]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceName attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:rssi attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:rssi attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:rssi attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:rssi attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
  
  return self;
}

@end
