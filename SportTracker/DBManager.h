//
//  DBManager.h
//  SportTracker
//
//  Created by Domenico Barretta on 10/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject

@property (strong, nonatomic)NSMutableArray *arrColumnNames;
@property (nonatomic)int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

- (instancetype)initWithDatabaseName:(NSString *)dbFilename;

- (NSArray *)loadDataFromDB:(NSString *)query;

- (void)executeQuery:(NSString *)query;

@end
