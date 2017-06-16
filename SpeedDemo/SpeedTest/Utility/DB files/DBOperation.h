 
#import <Foundation/Foundation.h>
#import <sqlite3.h>
/**
 to create connection & operation with database this class use.
 */
@interface DBOperation : NSObject 
{
}
/**
    connect to given database filename.
 */
+(void)OpenDatabase:(NSString*)path;  //Open the Database
+(void)finalizeStatements;//Closing and do the final statement at application exits
/**
 create database in document folder if not exist.
 */
+(void)checkCreateDB;
/**
 method to make database operation. like insert, delete and update.
 */
+(BOOL) executeSQL:(NSString *)sqlTmp;
/**
 method for use to get data from database table.
 */
+(NSMutableArray*) selectData:(NSString *)sql;


@end
