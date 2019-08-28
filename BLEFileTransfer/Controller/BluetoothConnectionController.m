//
//  BluetoothConnectionController.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 20/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "BluetoothConnectionController.h"



@interface BluetoothConnectionController ()

@end

@implementation BluetoothConnectionController
@synthesize stackView,ClientButton,ServerButton;

- (void)viewDidLoad {
    [super viewDidLoad];
  self.navigationController.navigationBar.hidden = YES;
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
//  NSString *string = @"ManiRecivedText";
//  NSError *error = NULL;
//  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"RecivedText" options:NSRegularExpressionCaseInsensitive error:&error];
//  NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
//  NSLog(@"Found %lu",(unsigned long)numberOfMatches);
  
  
  CGRect frame = self.view.frame;
  
  ClientButton = [UIButton buttonWithType:UIButtonTypeCustom];
  ClientButton.layer.cornerRadius = 4;
  ClientButton.layer.borderWidth = 1;
  ClientButton.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
  [ClientButton setTitleColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] forState:UIControlStateNormal];
  ClientButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
  [ClientButton setTitle:@"Central" forState:UIControlStateNormal];
  [ClientButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]];
  [ClientButton addTarget:self action:@selector(clientTapped) forControlEvents:UIControlEventTouchUpInside];
  ClientButton.translatesAutoresizingMaskIntoConstraints = NO;

  NSLayoutConstraint * equal_w = [NSLayoutConstraint constraintWithItem:ClientButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:frame.size.width/2];
  NSLayoutConstraint * equal_h = [NSLayoutConstraint constraintWithItem:ClientButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:50];
  
  [ClientButton addConstraints:@[equal_w,equal_h]];

  ServerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  ServerButton.layer.cornerRadius = 4;
  ServerButton.layer.borderWidth = 1;
  ServerButton.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
  [ServerButton setTitleColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] forState:UIControlStateNormal];
  ServerButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
  [ServerButton setTitle:@"Peripheral" forState:UIControlStateNormal];
  [ServerButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]];
  [ServerButton addTarget:self action:@selector(serverBtnTapped) forControlEvents:UIControlEventTouchUpInside];
  ServerButton.translatesAutoresizingMaskIntoConstraints = NO;
  

  NSLayoutConstraint * equal_w1 = [NSLayoutConstraint constraintWithItem:ServerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0  constant:frame.size.width/2];
  NSLayoutConstraint * equal_h1 = [NSLayoutConstraint constraintWithItem:ServerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:50];
  [ServerButton addConstraints:@[equal_w1,equal_h1]];
  
  stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
  stackView.axis = UILayoutConstraintAxisVertical;
  stackView.distribution = UIStackViewDistributionEqualSpacing;
  stackView.alignment = UIStackViewAlignmentCenter;
  stackView.spacing = 30;
  
  [stackView addArrangedSubview:ClientButton];
  [stackView addArrangedSubview:ServerButton];
  
  stackView.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:stackView];
  
  NSLayoutConstraint * Centerx = [NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
  NSLayoutConstraint * CenterY = [NSLayoutConstraint constraintWithItem:stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];

  [self.view addConstraints:@[Centerx,CenterY]];
  
}


-(void)serverBtnTapped{
    ClientViewController *obj = [[ClientViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

-(void)clientTapped{
    ShowBluetoothDevicesController *obj = [[ShowBluetoothDevicesController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

@end
