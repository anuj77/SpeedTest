//
//  DatabaseManager.h

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class FMDatabaseQueue;
@class Friend;

@interface DatabaseManager : NSObject {
}

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));


/*Singleton getter*/
+ (DatabaseManager *)sharedInstance;


-(BOOL)insertInLocationTable:(NSString *)date latitude:(double)latitude longitude:(double)longitude;
-(NSMutableArray *)getLocationData;


@end
