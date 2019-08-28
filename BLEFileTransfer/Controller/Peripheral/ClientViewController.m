//
//  ClientViewController.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 20/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "ClientViewController.h"


@interface ClientViewController () <BluetoothPeripheralDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
  NSMutableData *da;
}
@end

@implementation ClientViewController
@synthesize imagview, connectedLabel,IndicatorView, ShowMessageFeild, sendText, sendImage, advitiseBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
  

  [BTLEPeripheral sharedInstance].BleDelegate = self;
  [BTLEPeripheral sharedInstance].initiateDelegatePeripheral;
  
  
  
  self.navigationController.navigationBar.hidden = NO;
  da = [[NSMutableData alloc] init];

  advitiseBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
  advitiseBtn.translatesAutoresizingMaskIntoConstraints = NO;
  [advitiseBtn setOn:NO animated:YES];
  [advitiseBtn addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];
  [self.view addSubview:advitiseBtn];
  
  self.title = @"Receiving Informarions";
  [self.view setBackgroundColor:[UIColor whiteColor]];
  
  self.navigationItem.rightBarButtonItem =
  [[UIBarButtonItem alloc] initWithTitle:@"SendText"
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(sendTextMessage)];
  
  CGRect frame = self.view.frame;
  ShowMessageFeild = [[UITextView alloc] initWithFrame:CGRectZero];
  ShowMessageFeild.textColor = [UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0];
  ShowMessageFeild.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
  ShowMessageFeild.backgroundColor=[UIColor whiteColor];
  ShowMessageFeild.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
  ShowMessageFeild.delegate = self;
  ShowMessageFeild.layer.borderWidth = 0.5;
  ShowMessageFeild.layer.borderColor = UIColor.blueColor.CGColor;
  ShowMessageFeild.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:ShowMessageFeild];
  
  sendText = [UIButton buttonWithType:UIButtonTypeCustom];
  sendText.layer.cornerRadius = 4;
  sendText.layer.borderWidth = 1;
  sendText.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
  [sendText setTitleColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] forState:UIControlStateNormal];
  sendText.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
  [sendText setTitle:@"SendText" forState:UIControlStateNormal];
  [sendText.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]];
  [sendText addTarget:self action:@selector(TextTapped) forControlEvents:UIControlEventTouchUpInside];
  sendText.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:sendText];
  
  
  sendImage = [UIButton buttonWithType:UIButtonTypeCustom];
  sendImage.layer.cornerRadius = 4;
  sendImage.layer.borderWidth = 1;
  sendImage.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
  [sendImage setTitleColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] forState:UIControlStateNormal];
  sendImage.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
  [sendImage setTitle:@"SendImage" forState:UIControlStateNormal];
  [sendImage.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]];
  [sendImage addTarget:self action:@selector(ImageTapped) forControlEvents:UIControlEventTouchUpInside];
  sendImage.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:sendImage];
  
  connectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  connectedLabel.text = @"Waiting to connect";
  connectedLabel.layer.borderWidth = 1.0;
  connectedLabel.textAlignment = NSTextAlignmentCenter;
  connectedLabel.layer.borderColor = UIColor.blueColor.CGColor;
  connectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:connectedLabel];
  
  imagview = [[UIImageView alloc]initWithFrame:CGRectZero];
  imagview.layer.borderWidth = 1.0;
  imagview.layer.borderColor = UIColor.lightGrayColor.CGColor;
  imagview.layer.cornerRadius = 4;
  [self.view addSubview:imagview];
  imagview.translatesAutoresizingMaskIntoConstraints = NO;
  
  // Design Indicator
  IndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(imagview.bounds.size.width/2, imagview.bounds.size.height/2, 80, 80)];
  IndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  IndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
  IndicatorView.color = [UIColor whiteColor];
  IndicatorView.layer.cornerRadius = 5;
  IndicatorView.layer.masksToBounds = YES;
  [imagview addSubview:IndicatorView];
  [IndicatorView setCenter:imagview.center];
  [IndicatorView setTranslatesAutoresizingMaskIntoConstraints:TRUE];
  [IndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
  [imagview bringSubviewToFront:IndicatorView];
  [IndicatorView setTranslatesAutoresizingMaskIntoConstraints:TRUE];
  IndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  

  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:advitiseBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:advitiseBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:advitiseBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.navigationController.navigationBar.frame.size.height*2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:advitiseBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];

  
  NSLayoutConstraint * c_11 =[NSLayoutConstraint constraintWithItem:imagview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
  NSLayoutConstraint * c_21 =[NSLayoutConstraint constraintWithItem:imagview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:200];
  NSLayoutConstraint * equal_w1 = [NSLayoutConstraint constraintWithItem:imagview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:frame.size.width/2];
  NSLayoutConstraint * equal_h1 = [NSLayoutConstraint constraintWithItem:imagview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:frame.size.height/3];
  [self.view addConstraints:@[c_11,c_21]];
  [imagview addConstraints:@[equal_w1,equal_h1]];
  

  NSLayoutConstraint * c_111 =[NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
  NSLayoutConstraint * c_211 =[NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:advitiseBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10];
  NSLayoutConstraint * equal_w11 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20];
  NSLayoutConstraint * equal_h11 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20];
  NSLayoutConstraint * equal_h111 = [NSLayoutConstraint constraintWithItem:connectedLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:50];
  [self.view addConstraints:@[c_111,c_211,equal_w11,equal_h11,equal_h111]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ShowMessageFeild attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width-50]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ShowMessageFeild attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ShowMessageFeild attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imagview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ShowMessageFeild attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imagview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendText attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendText attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:ShowMessageFeild attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendText attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:ShowMessageFeild attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:frame.size.width/2]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:sendText attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sendText attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
  
}

- (void) switchToggled:(id)sender {
  UISwitch *mySwitch = (UISwitch *)sender;
  if ([mySwitch isOn]) {
    [[BTLEPeripheral sharedInstance] startAdvertising];
  } else {
     [[BTLEPeripheral sharedInstance] stopAdvertising];
  }
}

-(void)TextTapped {
  if (ShowMessageFeild.text.length == 0){
    [self showMessage:@"Enter the text to send" withTitle:@""];
  }else{
    [[BTLEPeripheral sharedInstance] sendText:ShowMessageFeild.text];
  }
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
    
    [addressesDict setObject:Name.text forKey:@"ptName"];
    [addressesDict setObject:History.text forKey:@"clinicalHistory"];
    [addressesDict setObject:Comments.text forKey:@"comments"];
    [addressesDict setObject:Impression.text forKey:@"impression"];
    
    
    NSLog(@"myString %@",addressesDict);
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:addressesDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"myString %@",myString);
    [[BTLEPeripheral sharedInstance] sendText:myString];

  }]];
  [self presentViewController:alertController animated:YES completion:nil];
  
}

-(void)ImageTapped {
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
  
//   [[BTLEPeripheral sharedInstance] sendImage:[UIImage imageNamed:@"scan"]];
   [[BTLEPeripheral sharedInstance] sendImage:originalImage];
  imagview.image = originalImage;
  [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)progressBarCallback:(float)imageProgress{
  
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)connnectingStatus:(Boolean)status {
  if (status) {
    connectedLabel.text = @"Connnected";
  }else{
    connectedLabel.text = @"Disconnnected";
  }
}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//  [textField resignFirstResponder];
//  return true;
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  return YES;
}



- (void)receivingCallback:(NSData *)data{
  NSLog(@"12wqeuiweifu");
  [imagview bringSubviewToFront:IndicatorView];
//  [IndicatorView startAnimating];
  [da appendData:data];
  NSData *da1 = da;
  imagview.hidden = NO;
  UIImage *daq2 =  [UIImage imageWithData:da1];
  imagview.image = daq2;
}

- (void)didCompleteStatus {}

- (void)StartStringMessage:(NSData *)data{
  NSString *Message =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  ShowMessageFeild.text = Message;
}

- (void)imageReceived:(nonnull NSMutableData *)data {
  [IndicatorView stopAnimating];
  NSData *da1 = data;
  imagview.hidden = NO;
  imagview.image = [UIImage imageWithData:da1];
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
