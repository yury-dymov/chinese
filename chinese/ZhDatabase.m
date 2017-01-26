//
//  PFDatabase.m
//  Partner Finder
//
//  Created by Dymov, Yuri on 3/11/15.
//  Copyright (c) 2015 IBA. All rights reserved.
//

#import "ZhDatabase.h"

static ZhDatabase *_instance;

@interface ZhDatabase()

@property (nonatomic, strong) EGODatabase *_db;

@end

@implementation ZhDatabase
@synthesize _db;

- (id)init {
    if (!_instance) {
        self = [super init];
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"zhdb.sqlite3"];
//        NSLog(@"%@", dbPath);
        NSError *err = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
            NSString *initialDbPath = [[NSBundle mainBundle] pathForResource:@"zhdb" ofType:@"sqlite3"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:initialDbPath])
                [[NSFileManager defaultManager] copyItemAtPath:initialDbPath toPath:dbPath error:&err];
        }
        _db = [[EGODatabase alloc] initWithPath:dbPath];
        _instance = self;
        [_db open];
    }
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    if (!_instance) {
        return [super allocWithZone:zone];
    }
    return _instance;
}

+ (id)getInstance {
    if (!_instance)
        return [self new];
    return _instance;
}

- (EGODatabaseResult*)executeQuery:(NSString *)query {
    return [_db executeQuery:query];
}

- (EGODatabaseResult*)executeQuery:(NSString *)query parameters:(NSArray*)parameters{
    return [_db executeQuery:query parameters:parameters];
}


@end
