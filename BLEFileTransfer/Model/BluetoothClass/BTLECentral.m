//
//  BTLECentral.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 22/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "BTLECentral.h"

@implementation BTLECentral
{
  NSMutableData *receiveImagedata;
  Boolean receiveFlag;
}
@synthesize centralManager, NOTIFY_MTU, completion;
static id _instance;

- (id) init
{
  if (_instance == nil)
  {
    _instance = [super init];
  }
  return _instance;
}

+ (BTLECentral *) sharedInstance
{
  if (!_instance)
  {
    return [[BTLECentral alloc] init];
  }
  return _instance;
}

-(void) initiateDelegateCentral
{
  receiveFlag = true;
  receiveImagedata = [[NSMutableData alloc] init];
//  centralManager = [[CBCentralManager alloc] initWithDelegate:self queue: nil];
  centralManager = [[CBCentralManager alloc] initWithDelegate:self queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)];
  
}

- (void)connect:(CBPeripheral *)peripheral{
  [centralManager connectPeripheral:peripheral options:nil];
}

-(void)stopScanning{
  // Stop scanning
  [self.centralManager stopScan];
  NSLog(@"Scanning stopped");
}



#pragma mark - Central Methods

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  if (central.state != CBManagerStatePoweredOn) {
    // In a real app, you'd deal with all the states correctly
    return;
  }
  
  // The state must be CBCentralManagerStatePoweredOn...
  
  // ... so start scanning
  
  [self scan];
  
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
  [self.centralManager scanForPeripheralsWithServices:nil options:options];
  
  NSArray *array = [[NSArray alloc] init];
  
  CBUUID *deviceInfoUUID = [CBUUID UUIDWithString: SERVICE_UUID];
  array = [self.centralManager retrieveConnectedPeripheralsWithServices:@[deviceInfoUUID]];
  NSLog(@"Retrive Scanned Arrray: %@",array);
  
  NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
  
  

  if (peripheral.name == nil){
    return;
  }
    
  // Ok, it's in range - have we already seen it?
  if (self.discoveredPeripheral != peripheral) {
    
    // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
    self.discoveredPeripheral = peripheral;
    
    // And connect
//    NSLog(@"Connecting to peripheral %@", peripheral);
    
    NSInteger newRow = [RSSI integerValue];
    [_BleDelegate didComplete:peripheral withRssi:&newRow];
//    [self.centralManager connectPeripheral:peripheral options:nil];
  }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
//  [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
  NSLog(@"Peripheral Connected");
  NSLog(@"Peripheral Connected %@",peripheral);
  
  // Stop scanning
  [self.centralManager stopScan];
  NSLog(@"Scanning stopped");
  
  // Clear the data that we may already have
//  [self.data setLength:0];
  
  // Make sure we get the discovery callbacks
  peripheral.delegate = self;
  
  // Search only for services that match our UUID
  [peripheral discoverServices:nil];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
  if (error) {
    NSLog(@"Error discovering services: %@", [error localizedDescription]);
//    [self cleanup];
    return;
  }
  
  // Discover the characteristic we want...
  
  // Loop through the newly filled peripheral.services array, just in case there's more than one.
  for (CBService *service in peripheral.services) {
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID], [CBUUID UUIDWithString:CHARACTERISTIC_SENT_RECEIVE_ID]] forService:service];
  }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
  // Deal with errors (if any)
  if (error) {
    NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
//    [self cleanup];
    return;
  }
  
  // Again, we loop through the array, just in case.
  for (CBCharacteristic *characteristic in service.characteristics) {
    
    NSLog(@"characteristic ----------->%@",characteristic);
    
    // And check if it's the right one
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]]) {
      NSLog(@"CHARACTERISTIC_WRITE_UUID ----------->%@",characteristic);
      self.ConnectingPeripheral = peripheral;
      self.characterstics = characteristic;
      NOTIFY_MTU = [peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
      peripheral.delegate = self;
      [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_SENT_RECEIVE_ID]]){
       NSLog(@"CHARACTERISTIC_SENT_RECEIVE_ID ----------->%@",characteristic);
      self.ConnectingPeripheral = peripheral;
      self.textCharacterstics = characteristic;
      [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
  }
  // Once this is complete, we just need to wait for the data to come in.
}

-(void)sendData:(UIImage *)image{
  receiveFlag = true;
  [self Notification:@"Sending Images"];
  NSData *data = UIImagePNGRepresentation(image);
  NSLog(@"Original Image size--> %lu",(unsigned long)data.length);
//  UIImage *image1 = [UIImage imageNamed:@"1.png"];
  NSData *valData = UIImageJPEGRepresentation(image, 1.0);

  NSString *strData = [NSString stringWithFormat:@"Start%lu",(unsigned long)valData.length];
  NSLog(@"print%@",strData);
  NSData *Eom = [strData dataUsingEncoding:NSUTF8StringEncoding];
  [self.ConnectingPeripheral writeValue:Eom forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];

  self.dataToSend = valData;
  self.sendDataIndex = 0;
  [_BleDelegate progressBarCallback: 0.0];
  [self SendingBytes];
}

-(void)sendTextMessage:(NSString *)msg{
  self.TextMessageFlag = true;
  receiveFlag = true;
  NSString *str1 = [@"SendingJson" stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)msg.length]];
  NSData *Eom1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
   [self.ConnectingPeripheral writeValue:Eom1 forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];
  
  [self Notification:@"Sent Text Message"];
  NSData *SendingJsonValue = [msg dataUsingEncoding:NSUTF8StringEncoding];
  [self.ConnectingPeripheral writeValue:SendingJsonValue forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];
  
  NSData *SendingJsonValue1 = [@"Completed" dataUsingEncoding:NSUTF8StringEncoding];
  [self.ConnectingPeripheral writeValue:SendingJsonValue1 forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];
}



-(void)SendingBytes{
  self.TextMessageFlag = false;

  while (self.dataToSend.length > self.sendDataIndex) {
    
    NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
    
    
    float count = (10 * self.sendDataIndex)/ self.dataToSend.length;
    
    completion = count / 10;
    
    [_BleDelegate progressBarCallback: completion];
    
    if (amountToSend > NOTIFY_MTU) {
      amountToSend = NOTIFY_MTU;
    }

    NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
    
//    NSLog(@"Next Chunk is %lu bytes long.",(unsigned long)chunk.length);
    
    Boolean boolValue = (self.ConnectingPeripheral.canSendWriteWithoutResponse);

    if (!boolValue) {
      return;
    }
    
    [self.ConnectingPeripheral writeValue:chunk forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];
    
    self.sendDataIndex += amountToSend;
    
  }
  
  if (self.completionFlag == false) {
    float count = (10 * self.sendDataIndex)/ self.dataToSend.length;
    completion = count / 10;
    [_BleDelegate progressBarCallback: completion];
    
    NSData *Eom = [@"Completed" dataUsingEncoding:NSUTF8StringEncoding];
    [self.ConnectingPeripheral writeValue:Eom forCharacteristic:self.characterstics type:CBCharacteristicWriteWithoutResponse];
    
    [_BleDelegate connnectingStatus:false];
    [_BleDelegate didCompleteStatus];
    self.completionFlag = true;
    [self.ConnectingPeripheral setNotifyValue:YES forCharacteristic:self.characterstics];
    NSLog(@"SentAll the packets");
    [self Notification:@"Sent all the packets"];
    completion = 0.0;
  }
  
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral{
  if (self.TextMessageFlag == false){
   [self SendingBytes];
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
  
  if (error) {
    NSLog(@"didWriteValueForCharacteristic With error: %@", [error localizedDescription]);
    return ;
  }
  
  NSString *result = [[NSString alloc] initWithFormat:@"%@",characteristic.value];
  NSLog(@"%@",result);
  
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
  
   NSLog(@"didDiscoverDescriptorsForCharacteristic");

  
}

/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  
  if (error) {
    NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
    return;
  }
  
  NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
  
  if ([stringFromData containsString:@"SendingJson"]){
    receiveFlag = false;
  }else if ([stringFromData containsString:@"Start"]) {
  }else if ([stringFromData containsString:@"Completed"]){
    if (receiveFlag == false) {
      receiveFlag = true;
      NSLog(@"Text received");
    }else{
      [_BleDelegate receiveiImage:receiveImagedata];
       NSLog(@"Image received");
      receiveImagedata.length = 0;
    }
  }else {
    if (receiveFlag == false) {
      [self Notification:@"Text message Received from Central"];
      [_BleDelegate receiveiText:stringFromData];
    }else{
       NSLog(@"received image");
      [receiveImagedata appendData:characteristic.value];
    }
    
  }
  
//  NSLog(@"Received--->%@",stringFromData);
  
  
 /*
  if ([characteristic.UUID.UUIDString isEqual: @"2AA2"]){
      [self Notification:@"Text message Received from Central"];
    [_BleDelegate receiveiText:stringFromData];
  }else if ([characteristic.UUID isEqual:@"2AF1"]){
    if ([stringFromData containsString:@"Completed"]){
      [self Notification:@"Image Recived"];
      [_BleDelegate receiveiImage:receiveImagedata];
    }else if ([stringFromData containsString: @"Start"]){
    }else{
       [receiveImagedata appendData:characteristic.value];
    }
  }else if ([characteristic.UUID.UUIDString.lowercaseString isEqualToString:CHARACTERISTIC_SENT_RECEIVE_ID]){
    [self Notification:@"Text message Received from Central"];
    [_BleDelegate receiveiText:stringFromData];
  }else if ([stringFromData containsString:@"Completed"]){
    [self Notification:@"Image Received from Central"];
    [_BleDelegate receiveiImage:receiveImagedata];
  }else if ([stringFromData containsString: @"Start"]){
  }else{
    [receiveImagedata appendData:characteristic.value];
  }
  */
  
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

  if (error) {
    NSLog(@"Error changing notification state: %@", error.localizedDescription);
  }
  
  // Exit if it's not the transfer characteristic
  if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]]) {
    return;
  }
  
  NSLog(@"characteristic %@",characteristic);
  
//  // Notification has started
  if (characteristic.isNotifying) {
    [self Notification:@"Connected"];
    [_BleDelegate connnectingStatus:true];
    NSLog(@"Notification began on %@", characteristic);
  }
//
//  // Notification has stopped
  else {
    // so disconnect from the peripheral
    if ([characteristic.UUID.UUIDString isEqual: @"2AF1"]){
      
      if (self.completionFlag == true) {
        [self Notification:@"Disconnected"];
        [_BleDelegate connnectingStatus:false];
         NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
//         [self.centralManager cancelPeripheralConnection:peripheral];
       }else{
         [self Notification:@"Connected"];
        [_BleDelegate connnectingStatus:true];
      }
        [self Notification:@"Connected"];
         [_BleDelegate connnectingStatus:true];
    }else{
      [_BleDelegate connnectingStatus:false];
      [self Notification:@"Disconnected"];
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
       [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
  }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
 // [_BleDelegate connnectingStatus:false];
  NSLog(@"Peripheral Disconnected");
  //  self.discoveredPeripheral = nil;
  
  UIApplication *app=[UIApplication sharedApplication];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (app.applicationState == UIApplicationStateBackground) {
    [self Notification:@"Disconnected"];
    }else{
      [self Notification:@"Disconnected"];
    }
  });
}


- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
  NSLog(@"peripheral modified");
  [_BleDelegate connnectingStatus:false];
  UIApplication *app=[UIApplication sharedApplication];
  dispatch_async(dispatch_get_main_queue(), ^{

  if (app.applicationState == UIApplicationStateBackground) {
    [self Notification:@"Disconnected"];
  }else{
    [self Notification:@"Disconnected"];
  }
  });
//  if ([self.ConnectingPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
//    NSLog(@"Retrying");
//    [self.centralManager connectPeripheral:peripheral options:nil];
//  }

  
}

-(void)Notification:(NSString*)state{
  
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  
  [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
      // Notifications allowed
      UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
      
      UNNotificationAction *snoozeAction = [UNNotificationAction actionWithIdentifier:@"Snooze"
                                                                                title:@"Snooze" options:UNNotificationActionOptionNone];
      UNNotificationAction *deleteAction = [UNNotificationAction actionWithIdentifier:@"Delete"
                                                                                title:@"Delete" options:UNNotificationActionOptionDestructive];
      
      UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"UYLReminderCategory"
                                                                                actions:@[snoozeAction,deleteAction] intentIdentifiers:@[]
                                                                                options:UNNotificationCategoryOptionNone];
      NSSet *categories = [NSSet setWithObject:category];
      
      [center setNotificationCategories:categories];
      
      
      UNMutableNotificationContent *content = [UNMutableNotificationContent new];
      content.title = @"BLE Notifications";
      content.body = state;
      content.categoryIdentifier = @"UYLReminderCategory";
      content.sound = [UNNotificationSound defaultSound];
      
      UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
      
      NSString *identifier = @"UYLLocalNotification";
      UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
      
      [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Something went wrong: %@",error);
        }
      }];
    } else {
      // Notifications not allowed
    }
  }];
}

-(void)showMessage:(NSString*)message withTitle:(NSString *)title {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:^{
    }];
  });
}
 

@end
