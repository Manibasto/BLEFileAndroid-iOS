//
//  DescriptionViewController.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 19/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "DescriptionViewController.h"

@interface DescriptionViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,BluetoothCentralDelegate, UIPopoverPresentationControllerDelegate>
{
  NSTimer *stopWatchTimer;
  NSDate *startDate;
  int currMinute;
  int currSeconds;
  NSMutableData *dataImage;
}
@end

@implementation DescriptionViewController
@synthesize IndicatorView, pickerImage, imagePickerBtn, sendImageBtn, imageview, connectedLabel, progressview, time_date;


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.navigationBar.hidden = NO;
  dataImage = [[NSMutableData alloc] init];
  
  [[BTLECentral sharedInstance] stopScanning];
  [BTLECentral sharedInstance].BleDelegate = self;
  
  self.title = @"Send Informarions";
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
  imagePickerBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
  imagePickerBtn.layer.borderWidth = 1.0;
  imagePickerBtn.layer.borderWidth = 1.0;
  imagePickerBtn.layer.cornerRadius = 5.0;
  imagePickerBtn.layer.borderColor = UIColor.blueColor.CGColor;
  [imagePickerBtn setTitle:@"Pick the Image" forState:UIControlStateNormal];
  [imagePickerBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
  [imagePickerBtn addTarget:self action:@selector(imagepickerTapped) forControlEvents:UIControlEventTouchUpInside];
  imagePickerBtn.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:imagePickerBtn];
  
  imageview = [[UIImageView alloc] init];
  imageview.layer.borderWidth = 1.0;
  imageview.layer.borderColor = UIColor.lightGrayColor.CGColor;
  imageview.layer.cornerRadius = 4;
  imageview.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:imageview];
  
  sendImageBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
  sendImageBtn.layer.borderWidth = 1.0;
  sendImageBtn.layer.borderWidth = 1.0;
  sendImageBtn.layer.cornerRadius = 5.0;
  sendImageBtn.layer.borderColor = UIColor.blueColor.CGColor;
  [sendImageBtn setTitle:@"Send Image" forState:UIControlStateNormal];
  [sendImageBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
  [sendImageBtn addTarget:self action:@selector(sendImageBtnTapped) forControlEvents:UIControlEventTouchUpInside];
  sendImageBtn.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:sendImageBtn];
  
  connectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  connectedLabel.text = @"Status: Please Wait..";
  connectedLabel.layer.borderWidth = 1.0;
  connectedLabel.textAlignment = NSTextAlignmentCenter;
  connectedLabel.layer.borderColor = UIColor.blueColor.CGColor;
  connectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:connectedLabel];
  
  // Design Indicator
  IndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(imageview.bounds.size.width/2, imageview.bounds.size.height/2, 80, 80)];
  IndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  IndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
  IndicatorView.color = [UIColor whiteColor];
  IndicatorView.layer.cornerRadius = 5;
  IndicatorView.layer.masksToBounds = YES;
  
  [imageview addSubview:IndicatorView];
  [IndicatorView setCenter:imageview.center];
  [IndicatorView setTranslatesAutoresizingMaskIntoConstraints:TRUE];
  [IndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
  [imageview bringSubviewToFront:IndicatorView];
  [IndicatorView setTranslatesAutoresizingMaskIntoConstraints:TRUE];
  IndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  pickerImage = nil;
  
  self.navigationItem.rightBarButtonItem =
  [[UIBarButtonItem alloc] initWithTitle:@"SendText"
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(sendTextMessage)];
  
  progressview = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  progressview.progressTintColor = [UIColor colorWithRed:187.0/255 green:160.0/255 blue:209.0/255 alpha:1.0];
  [[progressview layer]setFrame:CGRectMake(20, 50, 200, 200)];
  [[progressview layer]setBorderColor:[UIColor redColor].CGColor];
  progressview.trackTintColor = [UIColor clearColor];
  [progressview setProgress:(float)(50/100) animated:YES];  ///15
  [[progressview layer]setCornerRadius:10];
  [[progressview layer]setBorderWidth:1];
  [[progressview layer]setMasksToBounds:TRUE];
  progressview.clipsToBounds = YES;
  [self.view addSubview:progressview];
  [progressview setProgress:0.0];
  progressview.translatesAutoresizingMaskIntoConstraints = NO;
  
  time_date = [[UILabel alloc] initWithFrame:CGRectZero];
  time_date.textAlignment = NSTextAlignmentCenter;
  time_date.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:time_date];
  
  CGRect frame = self.view.frame;
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sendImageBtn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:sendImageBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:time_date attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:time_date attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:time_date attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:progressview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:time_date attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:progressview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
  
  NSLayoutConstraint * c_111 =[NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
  NSLayoutConstraint * c_211 =[NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.navigationController.navigationBar.frame.size.height*3];
  NSLayoutConstraint * equal_w11 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20];
  NSLayoutConstraint * equal_h11 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20];
  NSLayoutConstraint * equal_h111 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:50];
  [self.view addConstraints:@[c_111,c_211,equal_w11,equal_h11,equal_h111]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imagePickerBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imagePickerBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imagePickerBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:connectedLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imagePickerBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:10.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.height/3]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imagePickerBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imagePickerBtn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImageBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImageBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImageBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImageBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imageview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
}

-(void)sendTextMessage {
  
  // grab the view controller we want to show

  UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Send Text"
                                                                            message: @""
                                                                     preferredStyle:UIAlertControllerStyleAlert];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Pation Name";
    textField.textColor = [UIColor blueColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
  }];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Clinic History";
    textField.textColor = [UIColor blueColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
  }];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Comments";
    textField.textColor = [UIColor blueColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
  }];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Impression";
    textField.textColor = [UIColor blueColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
  }];
  [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    NSArray * textfields = alertController.textFields;
    UITextField * Name = textfields[0];
    UITextField * History = textfields[1];
    UITextField * Comments = textfields[2];
    UITextField * Impression = textfields[3];
    
    
    NSMutableDictionary *addressesDict = [[NSMutableDictionary alloc] init];
    
    [addressesDict setObject:Name.text forKey:@"Pation Name"];
    [addressesDict setObject:History.text forKey:@"Clinic History"];
    [addressesDict setObject:Comments.text forKey:@"Comments"];
    [addressesDict setObject:Impression.text forKey:@"Impression"];
    
    
    NSLog(@"myString %@",addressesDict);

    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:addressesDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"myString %@",myString);
    
    [[BTLECentral sharedInstance] sendTextMessage: myString];
  }]];
  [self presentViewController:alertController animated:YES completion:nil];

}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
  return true;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
  return UIModalPresentationNone;
}


- (void)viewWillAppear:(BOOL)animated{
  if (pickerImage == nil) {
    progressview.hidden = YES;
    imageview.hidden = YES;
    sendImageBtn.hidden = YES;
  }else{
    progressview.hidden = YES;
    imageview.image = pickerImage;
    imageview.hidden = NO;
    sendImageBtn.hidden = NO;
  }
}

-(void)sendImageBtnTapped{
  progressview.hidden = NO;
  if (stopWatchTimer) {
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
  }
  
  startDate = [NSDate date];
  
  // Create the stop watch timer that fires every 100 ms
  stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                    target:self
                                                  selector:@selector(updateTimer)
                                                  userInfo:nil
                                                   repeats:YES];
  [self.IndicatorView startAnimating];
  if (self.pickerImage != nil){
    self.sendImageBtn.enabled = NO;
    [[BTLECentral sharedInstance] sendData:self.pickerImage];
    [self.view bringSubviewToFront:self->IndicatorView];
  }else{
    [self.IndicatorView stopAnimating];
    NSLog(@"Sending Images-->nill");
  }
}


-(void)imagepickerTapped{
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Attach image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* pickFromGallery = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action) {
      if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
      {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:NULL];
      }
    }];
    UIAlertAction* takeAPicture = [UIAlertAction actionWithTitle:@"Choose from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
      UIImagePickerController* picker = [[UIImagePickerController alloc] init];
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      picker.delegate = self;
      [self presentViewController:picker animated:YES completion:NULL];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }];
    
    [alertController addAction:pickFromGallery];
    [alertController addAction:takeAPicture];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
  }else{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Profile Photo"  message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^void (UIAlertAction *action) {
      if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
      {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:NULL];
      }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose from gallery" style:UIAlertActionStyleDefault handler:^void (UIAlertAction *action) {
      UIImagePickerController* picker = [[UIImagePickerController alloc] init];
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      picker.delegate = self;
      [self presentViewController:picker animated:YES completion:NULL];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^void (UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
  UIImage *originalImage = (UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage];
  
//  pickerImage = [UIImage imageNamed:@"scan"];
  
  pickerImage = originalImage;
  [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCompleteStatus {
  [stopWatchTimer invalidate];
  stopWatchTimer = nil;
  [self updateTimer];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.IndicatorView stopAnimating];
     self.sendImageBtn.enabled = YES;
  });
 
}

- (void)updateTimer
{
  // Create date from the elapsed time
  NSDate *currentDate = [NSDate date];
  NSTimeInterval timeInterval = [currentDate
                                 timeIntervalSinceDate:startDate];
  NSLog(@"time interval %f",timeInterval);
  
  //300 seconds count down
  NSTimeInterval timeIntervalCountDown = timeInterval;
  
  NSDate *timerDate = [NSDate
                       dateWithTimeIntervalSince1970:timeIntervalCountDown];
  
  // Create a date formatter
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"mm:ss"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
  
  // Format the elapsed time and set it to the label
  NSString *timeString = [dateFormatter stringFromDate:timerDate];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.time_date.text = [@"Time Interval: " stringByAppendingString:timeString];
  });
}

- (void)connnectingStatus:(Boolean)status {
  if (status){
    dispatch_async(dispatch_get_main_queue(), ^{
      self.connectedLabel.text = @"Status: Connected";
    });
  }else{
    [self didCompleteStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.connectedLabel.text = @"Status: Disconnected";
    });
  }
}


- (void)progressBarCallback:(float)imageProgress{
  [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:imageProgress] waitUntilDone:NO];
}

- (void)setLoaderProgress:(NSNumber *)progress{
  float fprogress = [progress floatValue];
  [progressview setProgress:fprogress animated:YES];
}

- (void)receiveiImage:(NSData *)data{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.imageview.hidden = NO;
    [self->dataImage appendData:data];
    NSData *da = self->dataImage;
    UIImage *image = [UIImage imageWithData:da];
    self.imageview.image  = image;
  });
}
- (void)receiveiText:(NSString *)string{
  [self showMessage:string withTitle:@""];
}


- (void)didComplete:(CBPeripheral *)peripheral withRssi:(NSInteger *)rssiValue{ }

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
