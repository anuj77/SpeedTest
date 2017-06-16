//
//  LocationManager.m
//  SpeedTest
//
//  Created by Anuj on 14/06/17.
//  Copyright © 2017 Anuj. All rights reserved.
//
#import "LocationManager.h"

@implementation LocationManager
@synthesize userLocation;

static LocationManager *sharedInstance = NULL;
// Get the shared instance and create it if necessary.

#pragma mark -  Singleton Methods
+ (LocationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(void)setupLocationManager
{
    if (!_clLoction)
    {
        _clLoction = [[CLLocationManager alloc]init];
        _clLoction.delegate = self;
        _clLoction.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [_clLoction requestAlwaysAuthorization];
        _clLoction.pausesLocationUpdatesAutomatically=NO;
    }
    
    //clear previous timer
    if (timerToTrackLocation ) {
        [timerToTrackLocation invalidate];
        timerToTrackLocation = nil;
    }

}
-(void)startLocation
{
    
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"ending background task");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    timerInterval = 300;//as this time speed will be 0 so timer should be update every 5 min
    
    if (_clLoction)
    {
        [_clLoction startUpdatingLocation];
        [_clLoction startMonitoringSignificantLocationChanges];
    }
    else{
        [self setupLocationManager];
        [_clLoction startUpdatingLocation];
        [_clLoction startMonitoringSignificantLocationChanges];
    }
}

-(void)stopLocation
{
    if (_clLoction)
    {
        [_clLoction stopUpdatingLocation];
        [_clLoction stopMonitoringSignificantLocationChanges];
    }
    
    //invavlidate the timer
    if (timerToTrackLocation) {
        [timerToTrackLocation invalidate];
        timerToTrackLocation=nil;
    }
}

+ (BOOL)getLocationStatus
{
    if (([CLLocationManager authorizationStatus]== kCLAuthorizationStatusRestricted ) || [CLLocationManager authorizationStatus]== kCLAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}


#pragma - mark Location manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userLocation = (CLLocation *)[locations lastObject];
    
    double speed = self.userLocation.speed;
    
    if (speed < 0) {
        speed = 0.0;
    }
    
    //Speed is provided in m/s so multiply by 3.6 for kmph or 2.23693629 for mph.
    speed = speed * 3.6;
   
    [self adjustTimerAsPerSpeed:speed];
   

    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self startLocation];
        
    }
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusNotDetermined)
    {
        [self stopLocation];
    }
    if ([self.delegate respondsToSelector:@selector(locationAccessChanged:)])
    {
        [self.delegate locationAccessChanged:status];
    }
}

#pragma mark - Set Timer Based On Speed
-(void)adjustTimerAsPerSpeed:(double)newSpeed{
    
    float newTimeInterval = 0.0;
    if (newSpeed>=80) {
        //update timer for 30 sec
        newTimeInterval = 30.0;
    }
    else if (newSpeed<80 && newSpeed>=60){
        //update timer for 60 sec (1 min)
        newTimeInterval = 60.0;
        
    }
    else if (newSpeed<60 && newSpeed>=30){
        //update timer for 120 sec (2 min)
        newTimeInterval = 120.0;
        
    }
    else{
        //update timer for 300 sec(5 min)
        newTimeInterval = 300.0;
    }
    
    NSMutableDictionary *dictToSave = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:timerInterval],@"currentTimeInterval",[NSNumber numberWithFloat:timerInterval],@"newTimeInterval", nil];
    
    if (newTimeInterval != timerInterval) {
        
        //set new timer interval to track and save user's location
        [timerToTrackLocation invalidate];
        timerToTrackLocation = nil;
        
        //increase and decrease timer gradually
        if (timerInterval==30.0 && newTimeInterval > 30.0) {
            timerInterval = 60.0;
        }
        else if (timerInterval==60.0 && newTimeInterval > 60.0) {
            timerInterval = 120.0;
        }
        else if (timerInterval==120.0 && newTimeInterval > 120.0) {
            timerInterval = 300.0;
        }
        else if (timerInterval==300.0 && newTimeInterval >= 300.0) {
            timerInterval = 300.0;
        }
        else if (timerInterval==30.0 && newTimeInterval <= 30.0) {
            timerInterval = 30.0;
        }
        else if (timerInterval==60.0 && newTimeInterval < 60.0) {
            timerInterval = 30.0;
        }
        else if (timerInterval==120.0 && newTimeInterval < 120.0) {
            timerInterval = 60.0;
        }
        else if (timerInterval==300.0 && newTimeInterval < 300.0) {
            timerInterval = 120.0;
        }
        else{
            timerInterval=newTimeInterval;
        }
        [dictToSave setObject:[NSNumber numberWithFloat:timerInterval] forKey:@"newTimeInterval"];
        timerToTrackLocation = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(saveUserLocation:) userInfo:dictToSave repeats:YES];
        
    }
    else{
        
        //keep previous timer running & create timer if timer is not set or invalid
        timerInterval = newTimeInterval;
        [dictToSave setObject:[NSNumber numberWithFloat:timerInterval] forKey:@"currentTimeInterval"];
        [dictToSave setObject:[NSNumber numberWithFloat:timerInterval] forKey:@"newTimeInterval"];
        if (!timerToTrackLocation && !timerToTrackLocation.isValid) {
            timerToTrackLocation = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(saveUserLocation:) userInfo:dictToSave repeats:YES];
        }
    }
   
   
   
    dictToSave=nil;
}

#pragma mark - Store Location Data into File & DB
-(void)saveUserLocation:(NSTimer*)timer
{
    //Get the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/location.txt",documentsDirectory];
    
    //get date in string formate
    NSString *currentDate = [NSDate convertDateIntoStorableFormate:[NSDate date]];
    
    //Create string to set
    NSString *content = [NSString stringWithFormat:@"%@ %f %f %@ %@ \n",currentDate,self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude,[timer.userInfo objectForKey:@"currentTimeInterval"],[timer.userInfo objectForKey:@"newTimeInterval"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        
        //append data on same file
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        
        //create new file and save it to directory
        [content writeToFile:fileName  atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        
    }
    
    //Store Data in DB
    if (!dbmanager) {
        dbmanager = [DatabaseManager sharedInstance];
    }
    [dbmanager insertInLocationTable:currentDate latitude:self.userLocation.coordinate.latitude longitude:self.userLocation.coordinate.longitude];
    //clearing objects
    paths=nil;
    documentsDirectory=nil;
    fileName=nil;
    currentDate=nil;
    currentDate=nil;
    content=nil;
}
@end
