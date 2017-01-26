
#import "BaseObject.h"

@interface Word : BaseObject

@property (nonatomic, strong) NSString *native;
@property (nonatomic, strong) NSString *transcription;
@property (nonatomic, strong) NSString *translation;
@property (nonatomic, assign) BOOL isFavorite;

+ (NSArray*)findAllFavorites;

@end

