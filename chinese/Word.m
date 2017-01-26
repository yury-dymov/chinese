#import "Word.h"

@interface Word()


@end

@implementation Word

static BOOL _tableCreated = NO;

@synthesize native;
@synthesize transcription;
@synthesize translation;
@synthesize isFavorite;

+ (void)_createTable {
    if (!_tableCreated) {
        _tableCreated = YES;
        [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ("
                                                "id INTEGER PRIMARY KEY,"
                                                "native TEXT,"
                                                "transcription TEXT,"
                                                "translation TEXT,"
                                                "favorite INTEGER DEFAULT 0,"
                                                "created_at INTEGER,"
                                                "updated_at INTEGER)", NSStringFromClass([self class])]];
    }
}

+ (NSDictionary*)_mapping {
    return @{
             @"id" : @"id_",
             @"native" : @"native",
             @"transcription" : @"transcription",
             @"translation" : @"translation",
             @"created_at" : @"_icreatedAt",
             @"updated_at" : @"_iupdatedAt"
             };
}
- (void)save {
    [[self class] _createTable];
    BOOL isFav = self.id_ && self.isFavorite;
    [self rm];
    [[ZhDatabase getInstance] executeQuery:
     [NSString stringWithFormat:@"INSERT INTO '%@' (id, native, transcription, translation, created_at, updated_at, favorite) "
      "VALUES(%lu, ?, ?, ?, %lu, %lu, %d)",
      [self class], (unsigned long)self.id_, (unsigned long)self._icreatedAt, (unsigned long)self._iupdatedAt, isFav]
                                parameters:@[self.native, self.transcription, self.translation]
     ];
}

+ (id)_makeElemFromRow:(EGODatabaseRow *)row {
    Word *ret = [Word new];
    ret.id_ = [row longForColumn:@"id"];
    ret.native = [row stringForColumn:@"native"];
    ret.transcription = [row stringForColumn:@"transcription"];
    ret.translation = [row stringForColumn:@"translation"];
    ret.isFavorite = [row boolForColumn:@"favorite"];
    ret._iupdatedAt = [row longForColumn:@"updated_at"];
    ret._icreatedAt = [row longForColumn:@"created_at"];
    return ret;
}

+ (NSArray*)findAllFavorites {
    [self _createTable];
    NSMutableArray *ret = [NSMutableArray new];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM '%@' WHERE favorite = 1", [self class]]];
    for (EGODatabaseRow *row in res) {
        [ret addObject:[self _makeElemFromRow:row]];
    }
    return ret;
}



@end
