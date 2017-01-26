#import "TopicToWord.h"

@interface TopicToWord()


@end

@implementation TopicToWord

static BOOL _tableCreated = NO;

@synthesize topicId;
@synthesize wordId;
@synthesize word;
@synthesize topic;

+ (void)_createTable {
    if (!_tableCreated) {
        _tableCreated = YES;
        [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ("
                                                "id INTEGER PRIMARY KEY,"
                                                "topic_id INTEGER,"
                                                "word_id INTEGER,"
                                                "created_at INTEGER,"
                                                "updated_at INTEGER)", NSStringFromClass([self class])]];
    }
}

+ (NSDictionary*)_mapping {
    return @{
             @"id" : @"id_",
             @"topic_id" : @"topicId",
             @"word_id" : @"wordId",
             @"created_at" : @"_icreatedAt",
             @"updated_at" : @"_iupdatedAt"
             };
}

- (Word*)word {
    if (!word) {
        self.word = [Word findById:self.wordId];
    }
    return word;
}

- (Topic*)topic {
    if (!topic) {
        self.topic = [Topic findById:self.topicId];
    }
    return topic;
}

- (void)save {
    [[self class] _createTable];
    [self rm];
    [[ZhDatabase getInstance] executeQuery:
     [NSString stringWithFormat:@"INSERT INTO '%@' (id, topic_id, word_id, created_at, updated_at) "
      "VALUES(%lu, %lu, %lu, %lu, %lu)",
      [self class], (unsigned long)self.id_, (unsigned long)self.topicId, (unsigned long)self.wordId, (unsigned long)self._icreatedAt, (unsigned long)self._iupdatedAt]
                                parameters:@[]
     ];
}

+ (id)_makeElemFromRow:(EGODatabaseRow *)row {
    TopicToWord *ret = [TopicToWord new];
    ret.id_ = [row longForColumn:@"id"];
    ret.topicId = [row longForColumn:@"topic_id"];
    ret.wordId = [row longForColumn:@"word_id"];
    ret._iupdatedAt = [row longForColumn:@"updated_at"];
    ret._icreatedAt = [row longForColumn:@"created_at"];
    return ret;
}

+ (NSArray*)findWordsByTopic:(NSUInteger)topicId {
    NSMutableArray *ids = [NSMutableArray new];
    EGODatabaseResult *res = [[ZhDatabase getInstance] executeQuery:[NSString stringWithFormat:@"SELECT word_id FROM '%@' WHERE topic_id=%lu", NSStringFromClass([self class]), (unsigned long)topicId]];
    for (EGODatabaseRow *row in res) {
        [ids addObject:[NSNumber numberWithLong:[row longForColumn:@"word_id"]]];
    }
    return [Word findByIds:ids];
}

@end