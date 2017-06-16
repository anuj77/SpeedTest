//
//  LocationManager.h
//  SpeedTest
//
//  Created by Anuj on 14/06/17.
//  Copyright © 2017 Anuj. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DatabaseManager.h"
#import "LocationManager.h"
#import "NSDate+SpeedTest.h"
@protocol LocationManagerDelegate <NSObject>

@optional

- (void) locationAccessChanged:(CLAuthorizationStatus)status;

@end
@interface LocationManager : NSObject<CLLocationManagerDelegate>
{
    NSTimer *timerToTrackLocation;
    float timerInterval;
    
    DatabaseManager *dbmanager;
    UIBackgroundTaskIdentifier bgTask;

}
@property (nonatomic,strong) CLLocationManager *clLoction;
@property (nonatomic,strong) CLLocation *userLocation;
@property (nonatomic,strong) id<LocationManagerDelegate> delegate;

+ (BOOL)getLocationStatus;
+ (LocationManager *)sharedInstance;
- (void)setupLocationManager;
- (void)startLocation;
- (void)stopLocation;
@end
