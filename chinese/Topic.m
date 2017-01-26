#import "Topic.h"
#import "TopicToWord.h"

#define S_ALL_WORDS @"Все слова"

@interface Topic()


@end

@implementation Topic

static BOOL _tableCreated = NO;

@synthesize title;
@synthesize position;

+ (void)_createTable {
    if (!_tableCreated) {
        _tableCreated = YES;
        [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ("
                                                "id INTEGER PRIMARY KEY,"
                                                "title TEXT,"
                                                "position INTEGER,"
                                                "created_at INTEGER,"
                                                "updated_at INTEGER)", NSStringFromClass([self class])]];
    }
}

+ (NSDictionary*)_mapping {
    return @{
             @"id" : @"id_",
             @"title" : @"title",
             @"position" : @"position",
             @"created_at" : @"_icreatedAt",
             @"updated_at" : @"_iupdatedAt"
             };
}
- (void)save {
    [[self class] _createTable];
    [self rm];
    [[ZhDatabase getInstance] executeQuery:
     [NSString stringWithFormat:@"INSERT INTO '%@' (id, title, position, created_at, updated_at) "
      "VALUES(%lu, ?, %ld, %lu, %lu)",
      [self class], (unsigned long)self.id_, (long)position, (unsigned long)self._icreatedAt, (unsigned long)self._iupdatedAt]
                                parameters:@[self.title]
     ];
}

+ (id)_makeElemFromRow:(EGODatabaseRow *)row {
    Topic *ret = [Topic new];
    ret.id_ = [row longForColumn:@"id"];
    ret.title = [row stringForColumn:@"title"];
    ret.position = [row intForColumn:@"position"];
    ret._iupdatedAt = [row longForColumn:@"updated_at"];
    ret._icreatedAt = [row longForColumn:@"created_at"];
    return ret;
}

- (NSArray*)words {
    if (!self.id_) {
        if ([self.title isEqualToString:S_ALL_WORDS]) {
            return [Word findAll];
        } else {
            return [Word findAllFavorites];
        }
    }
    return [TopicToWord findWordsByTopic:self.id_];
}

+ (NSArray*)findAll {
    [self _createTable];
    NSMutableArray *ret = [NSMutableArray new];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT * FROM '%@' ORDER BY position ASC", NSStringFromClass([self class])]];
    for (EGODatabaseRow *row in res) {
        [ret addObject:[self _makeElemFromRow:row]];
    }
    Topic *allWords = [Topic new];
    allWords.id_ = 0;
    allWords.title = S_ALL_WORDS;
    Topic *fav = [Topic new];
    fav.id_ = 0;
    fav.title = @"Избранное";
    [ret insertObject:allWords atIndex:0];
    [ret insertObject:fav atIndex:0];
    return ret;
}

@end