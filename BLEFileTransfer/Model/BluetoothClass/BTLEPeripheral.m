//
//  BTLEPeripheral.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 22/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "BTLEPeripheral.h"


@implementation BTLEPeripheral
{
  NSMutableData *receiveData;
  NSString *stringValue;
  Boolean receiveFlag;
  NSData *dataToSend1;
  NSInteger sendDataIndex1;
}

@synthesize centralDevice,NOTIFY_MTU, dataToSend, sendDataIndex, completion;
static id _instance;

- (id) init
{
  if (_instance == nil)
  {
    _instance = [super init];
  }
  return _instance;
}

+ (BTLEPeripheral *) sharedInstance
{
  if (!_instance)
  {
    return [[BTLEPeripheral alloc] init];
  }
  return _instance;
}

-(void) initiateDelegatePeripheral{
  dataToSend1 = [[NSData alloc] init];
  receiveFlag = true;
  receiveData = [[NSMutableData alloc] init];
  self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}


-(void)stopAdvertising{
  NSLog(@" Advertsing stopped");
  [self.peripheralManager stopAdvertising];
}

- (CBPeripheralManagerConnectionLatency) nextLatencyAfter:(CBPeripheralManagerConnectionLatency)latency {
  switch (latency) {
    case CBPeripheralManagerConnectionLatencyLow: return CBPeripheralManagerConnectionLatencyMedium;
    case CBPeripheralManagerConnectionLatencyMedium: return CBPeripheralManagerConnectionLatencyHigh;
    case CBPeripheralManagerConnectionLatencyHigh: return CBPeripheralManagerConnectionLatencyLow;
  }
}
- (NSString*)describeLatency:(CBPeripheralManagerConnectionLatency)latency {
  switch (latency) {
    case CBPeripheralManagerConnectionLatencyLow: return @"Low";
    case CBPeripheralManagerConnectionLatencyMedium: return @"Medium";
    case CBPeripheralManagerConnectionLatencyHigh: return @"High";
  }
}


#pragma mark - Peripheral Methods

-(void)startAdvertising {
  NSString * deviceName = [[UIDevice currentDevice] name];
  [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey: deviceName ,CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]] }];
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
  
  if (error != nil){
    return;
  }
  
  // Opt out from any other state
  if (peripheral.state != CBManagerStatePoweredOn) {
    return;
  }
  
  // We're in CBPeripheralManagerStatePoweredOn state...
  NSLog(@"peripheralManagerDidStartAdvertising.");
  
  
  // Start with the CBMutableCharacteristic
  
  
  self.charNotify = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_RECEIVE_ID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
  
  
  //    self.charTextUUID = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_SENT_RECEIVE_ID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
  
//  self.charWrite = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID] properties:CBCharacteristicPropertyWrite+CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
//
//  self.charRead = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_READ_UUID] properties:CBCharacteristicPropertyRead+CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
//
//  self.charReceive = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_RECEIVE_ID] properties:CBCharacteristicPropertyWriteWithoutResponse+CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
//
  self.charTextUUID = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_SENT_RECEIVE_ID] properties:CBCharacteristicPropertyWriteWithoutResponse+CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable+CBAttributePermissionsWriteable];
  
  
  CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID]
                                                                     primary:YES];
  
  // Add the characteristic to the service
//  transferService.characteristics = @[ self.charNotify, self.charWrite, self.charRead, self.charReceive, self.charTextUUID,];
    transferService.characteristics = @[self.charNotify,self.charTextUUID];
  
  
  NSLog(@"hh %@",transferService.characteristics);
  
  // And add it to the peripheral manager
  [self.peripheralManager addService:transferService];
  
}

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
  // Opt out from any other state
  if (peripheral.state != CBManagerStatePoweredOn) {
    return;
  }
  
  [self startAdvertising];
  // We're in CBPeripheralManagerStatePoweredOn state...
  NSLog(@"self.peripheralManager powered on.");
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
  
  if (error == nil){
    NSLog(@"peripheral %@",peripheral);
  }else{
    NSLog(@"peripheral %@",[error localizedDescription]);
  }
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
  [self Notification:@"Connected"];
  centralDevice = central;
  NOTIFY_MTU = central.maximumUpdateValueLength;

  NSLog(@"Central subscribed to characteristic");
  NSLog(@"Supported to BLE Device Info:--> %lu",(unsigned long)[central maximumUpdateValueLength]);
  [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
  [_BleDelegate connnectingStatus:true];
  
  // Get the data
}




/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
  centralDevice = nil;
  NSLog(@"Central unsubscribed from characteristic");
  [_BleDelegate connnectingStatus:false];
  
  UIApplication *app=[UIApplication sharedApplication];
  if (app.applicationState == UIApplicationStateBackground) {
    [self Notification:@"Disconnected"];
  }else{
    [self Notification:@"Disconnected"];
  }
  //  if ([peripheral isEqualToString:peripheral.identifier.UUIDString]) {
  //    NSLog(@"Retrying");
  //    [self.centralManager connectPeripheral:peripheral options:nil];
  //  }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
  
  NSLog(@"didReceiveWriteRequests");
  
  CBATTRequest*       request = [requests  objectAtIndex: 0];
  NSData*             request_data = request.value;
  CBCharacteristic*   write_char = request.characteristic;
  
  NSString *stringFromData = [[NSString alloc] initWithData:request_data encoding:NSUTF8StringEncoding];
  
  
  if ([stringFromData containsString:@"SendingJson"]){
    receiveFlag = false;
  }else if ([stringFromData containsString:@"Start"]) {
  }else if ([stringFromData containsString:@"Completed"]){
    if (receiveFlag == false) {
      receiveFlag = true;
      NSLog(@"Text received");
    }else{
       [_BleDelegate receivingCallback:receiveData];
      receiveData.length = 0;
      NSLog(@"Image received");
    }
  }else {
    if (receiveFlag == false) {
      [self Notification:@"Text message Received from Central"];
      [_BleDelegate StartStringMessage:request_data];

    }else{
      NSLog(@"received image");
      [receiveData appendData:request_data];
      [_BleDelegate receivingCallback:request_data];
    }
    
  }
  
  
//  if ([stringFromData containsString:@"SendingJson"]){
//  }else {
//    [self Notification:@"Text message Received from Central"];
//    [_BleDelegate StartStringMessage:request_data];
//  }
  
  

  
  /*
  if ([write_char.UUID.UUIDString.lowercaseString isEqual:CHARACTERISTIC_READ_UUID]){
    NSString *stringFromData = [[NSString alloc] initWithData:request_data encoding:NSUTF8StringEncoding];
    NSLog(@"stringFromData%@",stringFromData);
    if ([stringFromData containsString:@"Start"]){
    }else if ([stringFromData containsString:@"Completed"]){
      [self Notification:@"Image Recived"];
      NSLog(@"stringFromData%lu",(unsigned long)receiveData.length);
      [_BleDelegate receivingCallback:receiveData];
      NSLog(@"string");
    }else {
      NSLog(@"string%lu",(unsigned long)request_data.length);
      [receiveData appendData:request_data];
      [_BleDelegate receivingCallback:request_data];
    }
  }else if ([write_char.UUID.UUIDString.lowercaseString isEqual:CHARACTERISTIC_SENT_RECEIVE_ID]){
    [self Notification:@"Text Recived"];
    [_BleDelegate StartStringMessage:request_data];
  }
  */
}



-(void)sendImage:(UIImage*)image {
  receiveFlag = true;
  [self Notification:@"Send image from Peripheral"];
  NSData *lenthData = UIImageJPEGRepresentation(image, 1.0);
  NSString *strData = [NSString stringWithFormat:@"Start%lu",(unsigned long)lenthData.length];
  NSLog(@"print%@",strData);
  NSData *Eom = [strData dataUsingEncoding:NSUTF8StringEncoding];
  [self.peripheralManager updateValue:Eom forCharacteristic:self.charNotify onSubscribedCentrals:nil];
  self.dataToSend = lenthData;
  [self SendingBytes];
}

-(void)sendText:(NSString*)textMessage{
  stringValue = textMessage;
  receiveFlag = true;
  
  [self Notification:@"Send TextMessage from Peripheral"];
  
  NSString *str1 = [@"SendingJson" stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)textMessage.length]];
  NSData *Eom1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
//  dataToSend1 = Eom1;
//  sendDataIndex1 = 0;
  [self.peripheralManager updateValue:Eom1 forCharacteristic:self.charNotify onSubscribedCentrals:nil];
  
//  [self sendData:0];
  self.myTimerName = [NSTimer scheduledTimerWithTimeInterval: 1
                                                 target:self
                                               selector:@selector(handleTimer:)
                                               userInfo:nil
                                                repeats:NO];
}

-(void)handleTimer: (id) sender
{
  NSData *Eom = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
  
  dataToSend1 = Eom;
  sendDataIndex1 = 0;
//  [self.peripheralManager updateValue:Eom forCharacteristic:self.charNotify onSubscribedCentrals:nil];
//  [self sendData:0];
  [self sendData:0];
//  [myTimerName invalidate];
}

-(void)handle: (id) sender {
//  [myTimerName invalidate];
  NSData *Eom1 = [@"Completed" dataUsingEncoding:NSUTF8StringEncoding];
//  dataToSend1 = Eom1;
//  sendDataIndex1 = 0;
//  [self sendData:0];
  [self.peripheralManager updateValue:Eom1 forCharacteristic:self.charNotify onSubscribedCentrals:nil];
}






-(void)SendingBytes1{
  
  while (dataToSend1.length > sendDataIndex1) {
    NSInteger amountToSend = dataToSend1.length - sendDataIndex1;
    if (amountToSend > 20) {
      amountToSend = 20;
    }
    NSData *chunk = [NSData dataWithBytes:dataToSend1.bytes+sendDataIndex1 length:amountToSend];
//    NSString *dataString = [NSString stringWithUTF8String:[chunk bytes]];
    NSString *dataString = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];

    NSLog(@"Sending--->%@",dataString);
    
    [self.peripheralManager updateValue:chunk forCharacteristic:self.charNotify onSubscribedCentrals:nil];
    sendDataIndex1 += amountToSend;
    NSLog(@"Sending");
  }

  sendDataIndex1 = 0;
  dataToSend1 = 0;
  
  NSLog(@"SentAll the packets");
  // [_BleDelegate didCompleteStatus];
}



-(void)sendData:(NSInteger)IntValue{
  double delayInSeconds = 0.3;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    NSInteger amountToSend = self->dataToSend1.length - self->sendDataIndex1;
      if (amountToSend > self->NOTIFY_MTU) {
        amountToSend = self->NOTIFY_MTU;
      }
      NSData *chunk = [NSData dataWithBytes:self->dataToSend1.bytes+self->sendDataIndex1 length:amountToSend];
    [self.peripheralManager updateValue:chunk forCharacteristic:self.charNotify onSubscribedCentrals:nil];
      self->sendDataIndex1 += amountToSend;
    if (self->dataToSend1.length == self->sendDataIndex1){
      NSLog(@"Timer");
      double delayInSeconds = 0.2;
      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
      dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSData *Eom1 = [@"Completed" dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheralManager updateValue:Eom1 forCharacteristic:self.charNotify onSubscribedCentrals:nil];
      });
    }else{
      [self sendData:IntValue+1];
    }
  });
}






-(void)SendingBytes {
  
  // First up, check if we're meant to be sending an EOM
  static BOOL sendingEOM = NO;
  
  if (sendingEOM) {
    
    // send it
    BOOL didSend = [self.peripheralManager updateValue:[@"Completed" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.charNotify onSubscribedCentrals:nil];
    
    // Did it send?
    if (didSend) {
      
      // It did, so mark it as sent
      sendingEOM = NO;
      
      NSLog(@"Sent: EOM");
      
      self.dataToSend = nil;
    }
    
    // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
    return;
  }
  
  // We're not sending an EOM, so we're sending data
  
  // Is there any left to send?
  
  if (self.sendDataIndex >= self.dataToSend.length) {
    
    // No data left. Do nothing
    return;
  }
  
  // There's data left, so send until the callback fails, or we're done.
  
  BOOL didSend = YES;
  
  while (didSend) {
    
    // Make the next chunk
    
    // Work out how big it should be
    NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
    
    //    float count = (10 * self.sendDataIndex)/ self.dataToSend.length;
    //
    //    completion = count / 10;
    //
    //    [_BleDelegate progressBarCallback: completion];
    // Can't be longer than 20 bytes
    if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
    
    // Copy out the data we want
    NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
    
    // Send it
    didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.charNotify onSubscribedCentrals:nil];
    
    // If it didn't work, drop out and wait for the callback
    if (!didSend) {
      return;
    }
    
    NSLog(@"send %ld",(long)sendDataIndex);
    NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
    
    // It did send, so update our index
    self.sendDataIndex += amountToSend;
    
    // Was it the last one?
    if (self.sendDataIndex >= self.dataToSend.length) {
      
      // It was - send an EOM
      
      // Set this so if the send fails, we'll send it next time
      sendingEOM = YES;
      
      // Send it
      [self Notification:@"Send All the packet from Peripheral"];
      BOOL eomSent = [self.peripheralManager updateValue:[@"Completed" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.charNotify onSubscribedCentrals:nil];
      
      if (eomSent) {
        
        // It sent, we're all done
        sendingEOM = NO;
        
        
        NSLog(@"Sent: EOM");
      }
      
      return;
    }
  }
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


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
  NSLog(@"didReceiveReadRequest");
  // [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
  NSLog(@"didReceiveReadRequest SUCCESS");
}


- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
  [self SendingBytes];
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
