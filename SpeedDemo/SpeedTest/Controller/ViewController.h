//
//  ViewController.h
//  SpeedTest
//
//  Created by Anuj on 14/06/17.
//  Copyright © 2017 Anuj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"
#import "LocationManager.h"
#import "NSDate+SpeedTest.h"

@interface ViewController : UIViewController<LocationManagerDelegate>
{

    __weak IBOutlet UISwitch *switchLocation;

    LocationManager *objLocation;
    CLLocation *currentLocation;
    NSTimer *timerToTrackLocation;
    float timerInterval;
    
    DatabaseManager *dbmanager;
}

- (IBAction)switchLocation_Changed:(UISwitch*)sender;

@end

