//
//  ViewController.m
//  SpeedTest
//
//  Created by Anuj on 14/06/17.
//  Copyright © 2017 Anuj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //to avoid alertview display error we are adding delay here
    [self performSelector:@selector(checkLocationServiceAccess) withObject:nil afterDelay:0.3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action to turn on/off location tracking
- (IBAction)switchLocation_Changed:(UISwitch*)sender {

    if (!objLocation)
    {
        objLocation = [LocationManager sharedInstance];
        objLocation.delegate=self;
        [objLocation setupLocationManager];
    }
 
    if (sender.isOn) {
        if (![LocationManager getLocationStatus]) {
            [self showLocationAlertMessage];
            [sender setOn:FALSE];
        }
        else{
            [objLocation startLocation];
        }
    }
    else{
        [objLocation stopLocation];

    }
}

#pragma mark - Location Authorization Check
-(void)checkLocationServiceAccess{

    // Check for location permission
    if ([LocationManager getLocationStatus])
    {
        objLocation = [LocationManager sharedInstance];
        objLocation.delegate=self;
        [objLocation setupLocationManager];
        [objLocation startLocation];
        [switchLocation setOn:TRUE];

    }
    else{
        [self showLocationAlertMessage];
        [switchLocation setOn:FALSE];

    }
    
}
- (void)locationAccessChanged:(CLAuthorizationStatus)status
{
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [switchLocation setOn:TRUE];

        
    }
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusNotDetermined)
    {
         [switchLocation setOn:FALSE];
    }
    
}


-(void)showLocationAlertMessage
{
    if (([CLLocationManager authorizationStatus]== kCLAuthorizationStatusRestricted ) || [CLLocationManager authorizationStatus]== kCLAuthorizationStatusDenied)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert title" message:@"Your location services are disabled.Please enable location from settings to track your location" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        UIAlertAction* settings = [UIAlertAction actionWithTitle:@"Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary new] completionHandler:nil];
        }];
        [alertController addAction:settings];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


@end
