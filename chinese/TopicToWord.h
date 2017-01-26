#import "BaseObject.h"
#import "Word.h"
#import "Topic.h"

@interface TopicToWord : BaseObject

@property (nonatomic, assign) NSUInteger topicId;
@property (nonatomic, assign) NSUInteger wordId;

@property (nonatomic, strong) Topic *topic;
@property (nonatomic, strong) Word *word;

+ (NSArray*)findWordsByTopic:(NSUInteger)topicId;

@end