//
//  DatabaseManager.m


#import "DatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#define KEY_TABLE_LOCATION @"table_location"
#define kApplicationdatabasename @"SpeedTestdb.rdb"
@interface DatabaseManager () {
}
@property(strong, nonatomic) FMDatabaseQueue *databaseQueue;


@end

@implementation DatabaseManager

- (void)checkUpdates {
    
}

#pragma mark Singleton methods
+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(DatabaseManager *) [super alloc] initUniqueInstance];
    });
    return shared;
}

#pragma mark Data access methods
- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kApplicationdatabasename];
}
- (instancetype)initUniqueInstance
{
    self = [super init];
    if (self)
    {
        NSString *databasePath = [self dataFilePath];
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:databasePath];
    }
    return self;
}


+ (instancetype)alloc {
    return nil;
}

- (instancetype)init {
    return nil;
}

+ (instancetype)new {
    return nil;
}
#pragma mark - Insert Operations
-(BOOL)insertInLocationTable:(NSString *)date latitude:(double)latitude longitude:(double)longitude{
    
    @try {
        __block BOOL result = NO;
        
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            NSString *query = [NSString stringWithFormat:@"insert into %@ values('%@',%f,%f)",KEY_TABLE_LOCATION,date,latitude,longitude];
            result = [database executeUpdate:query];
        }];
        return result;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception == %@",[exception userInfo]);
        return NO;
    }
    
    
}
#pragma mark - Retreive Operations
-(NSMutableArray *)getLocationData
{
    @try {
        __block NSMutableArray *fetcheddata=[[NSMutableArray alloc] init];
        
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@",KEY_TABLE_LOCATION];
            FMResultSet *resultSet = [database executeQuery:query];
            while ([resultSet next]) {
                NSDictionary *dict=  [self locationWithResulSet:resultSet];
                [fetcheddata addObject: dict];
            }
            [resultSet close];
            
        }];
         return fetcheddata;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception == %@",[exception userInfo]);
        return nil;
    }

}
- (NSDictionary*)locationWithResulSet:(FMResultSet*)resultSet
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:[resultSet stringForColumn:@"date"] forKey:@"date"];
    [dict setObject:[resultSet stringForColumn:@"latitude"] forKey:@"latitude"];
    [dict setObject:[resultSet stringForColumn:@"longitude"] forKey:@"longitude"];
    return dict;
    
}

@end
