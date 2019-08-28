//
//  ViewController.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 19/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "ShowBluetoothDevicesController.h"



@interface ShowBluetoothDevicesController () <UITableViewDataSource, UITableViewDelegate,BluetoothCentralDelegate>
@end

@implementation ShowBluetoothDevicesController

@synthesize tableview, bottomButton, noDataLabel, scanview,scanImage, scanningLabel, peripherals, PairedPeripherals, rssiArray, refreshControl;

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad {
  [super viewDidLoad];
  
  peripherals = [NSMutableArray new];
  rssiArray   = [[NSMutableArray alloc] init];

  self.navigationController.navigationBar.hidden = YES;
  
  self.title = @"Devices";
  [self.view setBackgroundColor:[UIColor whiteColor]];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];

  noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableview.bounds.size.width, tableview.bounds.size.height)];
  
  scanview = [[UIView alloc] init];
  scanview.layer.borderWidth = 0.50;
  scanview.layer.borderColor = UIColor.lightGrayColor.CGColor;
  scanview.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:scanview];
  
  UIImage *backgroundLogoImage = [UIImage imageNamed:@"scan"];
  scanImage = [[UIImageView alloc] init];
  scanImage.image = backgroundLogoImage;
  scanImage.contentMode = UIViewContentModeScaleAspectFit;
  scanImage.translatesAutoresizingMaskIntoConstraints = NO;
  [scanview addSubview:scanImage];
  
  bottomButton = [[UIButton alloc] init];
  [bottomButton setTitle:@"Back" forState:UIControlStateNormal];
  [bottomButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
  bottomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  [bottomButton addTarget:self action:@selector(backPressed:)  forControlEvents:UIControlEventTouchUpInside];
  bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:bottomButton];
  
  scanningLabel = [[UILabel alloc] init];
  scanningLabel.text = @"Scanning Devices, Please Wait..";
  scanningLabel.textColor = UIColor.grayColor;
  scanningLabel.textAlignment = NSTextAlignmentCenter;
  scanningLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [scanview addSubview:scanningLabel];
  
  tableview = [[UITableView alloc] initWithFrame:CGRectZero];
  tableview.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addSubview:tableview];
  
  
  
  refreshControl = [[UIRefreshControl alloc]init];
  [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
  
  if (@available(iOS 10.0, *)) {
    self.tableview.refreshControl = refreshControl;
  } else {
    [self.tableview addSubview:refreshControl];
  }
  
  
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
  
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanningLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.frame.size.width]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanningLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanningLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  [scanview addConstraint:[NSLayoutConstraint constraintWithItem:scanningLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.frame.size.height/2-100]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scanview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scanview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
  
  if (@available(iOS 11.0, *)) {
    UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
                                              [bottomButton.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:0]
                                              ]];
  } else {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
  }
  
  tableview.layer.borderWidth = 0.50;
  tableview.layer.borderColor = UIColor.lightGrayColor.CGColor;

  // must set delegate & dataSource, otherwise the the table will be empty and not responsive
  tableview.delegate = self;
  tableview.dataSource = self;
  
  [self.tableview registerClass:DeviceListCell.class forCellReuseIdentifier:CellIdentifier];

  

  tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
  [self.tableview registerClass:DeviceListCell.class forCellReuseIdentifier:CellIdentifier];
  tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [self.view bringSubviewToFront:tableview];
  [self.view bringSubviewToFront:scanview];
  [self.view bringSubviewToFront:bottomButton];
  // add to canvas
//  [self.view addSubview:tableview];
  
}

- (void) refreshTable {
  //TODO: refresh your data
  [refreshControl endRefreshing];
  [self.peripherals removeAllObjects];
  [rssiArray removeAllObjects];  
  [self.tableview reloadData];
}
- (void)viewWillAppear:(BOOL)animated{
  PulsingHaloLayer *layer = [PulsingHaloLayer layer];
  self.halo = layer;
  [scanImage.superview.layer insertSublayer:self.halo below:self.scanImage.layer];
  [self setupInitialValues];
  [self.halo start];
    [self intiateSetup];
}

- (void)setupInitialValues {
  float value = floor(5);
  self.halo.haloLayerNumber = value;
  self.halo.radius = 0.7 * kMaxRadius;
  self.halo.animationDuration = 0.5 * kMaxDuration;
  UIColor *color = [UIColor colorWithRed:0
                                   green:0.455
                                    blue:0.756
                                   alpha:1.0];
  [self.halo setBackgroundColor:color.CGColor];
}

- (void) backPressed:(UIButton *) sender {
  [self.navigationController popViewControllerAnimated:true];
}

-(void)intiateSetup{
  [self.peripherals removeAllObjects];
  [rssiArray removeAllObjects];
  BTLECentral *instance = [BTLECentral sharedInstance];
  instance.BleDelegate = self;
  [[BTLECentral sharedInstance] initiateDelegateCentral];
}

- (void)viewDidLayoutSubviews{
  self.navigationController.navigationBar.hidden = YES;
  self.halo.position = CGPointMake(scanImage.center.x, scanImage.center.y);
}

-(void)refresh:(id)sender
{
  [self.peripherals removeAllObjects];
  [rssiArray removeAllObjects];
  [self.tableview reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
  [[BTLECentral sharedInstance] stopScanning];
}



//pragma mark - UITableViewDataSource

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
  if (peripherals.count == 0){
    dispatch_async(dispatch_get_main_queue(), ^{
      self.noDataLabel.text             = @"No devices found";
      self.noDataLabel.textColor        = [UIColor blackColor];
      self.noDataLabel.textAlignment    = NSTextAlignmentCenter;
      self.tableview.backgroundView = self.noDataLabel;
      self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    });
    return 0;
  }else{
    dispatch_async(dispatch_get_main_queue(), ^{
      self.noDataLabel.text             = @"";
    });
    return peripherals.count;
  }
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

  // Similar to UITableViewCell, but
  DeviceListCell *cell = [tableview dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  if (cell == nil) {
    cell = [[DeviceListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
    cell.deviceName.text =  [peripherals[indexPath.row] name];
    NSString *rssi = rssiArray[indexPath.row];
  
  NSInteger inf = [rssiArray[indexPath.row] integerValue];
  
    if (inf > -35) {
      cell.rssi.textColor = UIColor.greenColor;
    }else{
      cell.rssi.textColor = UIColor.redColor;
    }
    cell.rssi.text = [NSString stringWithFormat:@"%@",rssi];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  if (peripherals[indexPath.row] != nil || peripherals[indexPath.row]  != (id)[NSNull null]) {
    DescriptionViewController *obj = [[DescriptionViewController alloc] init];
    [[BTLECentral sharedInstance] connect:peripherals[indexPath.row]];
    [self.navigationController pushViewController:obj animated:YES];
  }
}


- (void)didRecievePairedData:(nonnull NSArray *)pairedList {
  NSLog(@"-->%@",pairedList);
  PairedPeripherals = pairedList;
}

- (void)didComplete:(CBPeripheral *)peripheral withRssi:(NSInteger *)rssiValue{
  if (peripheral != nil) {
    if (![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [self.rssiArray addObject: [NSNumber numberWithInteger:*rssiValue]];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
      });
    }
  }
}
- (void)connnectingStatus:(Boolean)status{}

- (void)didCompleteStatus{}

-(void)progressBarCallback:(float)imageProgress{}

@end


