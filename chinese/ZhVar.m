//
//  ZhVar.m
//  chinese
//
//  Created by Dymov, Yuri on 7/28/15.
//  Copyright (c) 2015 Dymov, Yuri. All rights reserved.
//

#import "ZhVar.h"
#import "ZhDatabase.h"

static BOOL _tableCreated = NO;

@implementation ZhVar
@synthesize key;
@synthesize value;

+ (void)_createTable {
    if (!_tableCreated) {
        _tableCreated = YES;
        [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ("
                                                "key STRING UNIQUE,"
                                                "value STRING)", NSStringFromClass([self class])]];
    }
}


- (void)save {
    [[self class] _createTable];
    [self rm];
    [[ZhDatabase getInstance] executeQuery:
     [NSString stringWithFormat:@"INSERT INTO '%@' (key, value) VALUES(?, ?)", [self class]] parameters:@[self.key, self.value]];
}

- (void)rm {
    [[self class] _createTable];
    [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"DELETE FROM '%@' WHERE key=?", NSStringFromClass([self class])] parameters:@[self.key]];
}

+ (id)_makeElemFromRow:(EGODatabaseRow*)row {
    ZhVar *ret = [ZhVar new];
    ret.key = [row stringForColumn:@"key"];
    ret.value = [row stringForColumn:@"value"];
    return ret;
}

+ (ZhVar*)findByKey:(NSString *)key {
    [self _createTable];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM '%@' WHERE key = ?", NSStringFromClass([self class])] parameters:@[key]];
    for (EGODatabaseRow *row in res)
        return [self _makeElemFromRow:row];
    return nil;
}


@end

