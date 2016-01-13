#import "MapAnnotations.h"

@implementation MKPointAnnotation (ReuseId)
+ (NSString *)reuseId
{
    return NSStringFromClass(self);
}
@end

@implementation AirportAnnotation

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

@end

@implementation PlaneAnnotation

@end
