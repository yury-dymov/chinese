//
//  BaseObject.m
//  Partner Finder
//
//  Created by Dymov, Yuri on 3/11/15.
//  Copyright (c) 2015 IBA. All rights reserved.
//

#import "BaseObject.h"
#import "SyncEngine.h"

@implementation BaseObject

@synthesize id_;
@synthesize createdAt;
@synthesize _icreatedAt;
@synthesize _iupdatedAt;
@synthesize updatedAt;

- (void)set_icreatedAt:(NSUInteger)_aicreatedAt {
    _icreatedAt = _aicreatedAt;
    self.createdAt = [NSDate dateWithTimeIntervalSince1970:_aicreatedAt * 0.001f];
}

- (void)set_iupdatedAt:(NSUInteger)_aiupdatedAt {
    _iupdatedAt = _aiupdatedAt;
    self.updatedAt = [NSDate dateWithTimeIntervalSince1970:_aiupdatedAt * 0.001f];
}

- (void)save {
    NSAssert(0, @"save not implemented");
}

- (void)rm {
    if (self.id_)
        [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"DELETE FROM '%@' WHERE id=%lu", NSStringFromClass([self class]), (unsigned long)self.id_]];
}

+ (void)synchronize {
    [self _createTable];
    [[SyncEngine getInstance] synchronizeObject:NSStringFromClass([self class])];
}

+ (void)_createTable {
    NSAssert(0, @"%@ createTable not implemented", [self class]);
}

+ (id)_makeElemFromRow:(EGODatabaseRow *)row {
    NSAssert(0, @"_makeElemFromRow not implemented");
    return nil;
}

+ (NSDictionary*)_mapping {
    NSAssert(0, @"_mapping not implemented");
    return @{};
}

+ (void)bulkSave:(NSArray *)objects {
    [self _createTable];
    [[ZhDatabase getInstance] executeQuery:@"BEGIN"];
    for (BaseObject *object in objects)
        [object save];
    [[ZhDatabase getInstance] executeQuery:@"COMMIT"];
}

+ (id)findById:(NSUInteger)anId {
    NSArray *ret = [self findByIds:@[[NSNumber numberWithInteger:anId]]];
    if (ret.count)
        return [ret firstObject];
    return nil;
}

+ (NSArray*)findByIds:(NSArray *)ids {
    [self _createTable];
    NSMutableArray *ret = [NSMutableArray new];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM '%@' WHERE id in (%@)", [self class], [ids componentsJoinedByString:@","]]];
    for (EGODatabaseRow *row in res) {
        [ret addObject:[self _makeElemFromRow:row]];
    }
    return ret;
    
}

+ (NSUInteger)getLastTimestamp {
    [self _createTable];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT updated_at FROM '%@' ORDER BY updated_at DESC LIMIT 1", [self class]]];
    for (EGODatabaseRow *row in res)
        return [row longForColumnAtIndex:0];
    return 0;
}

+ (NSArray*)findAll {
    [self _createTable];
    NSMutableArray *ret = [NSMutableArray new];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM '%@'", [self class]]];
    for (EGODatabaseRow * row in res)
        [ret addObject:[self _makeElemFromRow:row]];
    return ret;
}

+ (void)rmById:(NSUInteger)anId {
    [self internalRmByIds:[NSString stringWithFormat:@"%lu", (unsigned long)anId]];
}

+ (void)rmByIds:(NSArray *)ids {
    [self internalRmByIds:[ids componentsJoinedByString:@","]];
}

+ (void)internalRmByIds:(NSString *)ids {
    [self _createTable];
    [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"DELETE FROM '%@' WHERE id in (%@)", [self class], ids]];
    
}

@end
