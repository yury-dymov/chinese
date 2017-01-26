#import "BaseObject.h"

@interface Topic : BaseObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger position;

- (NSArray*)words;

@end