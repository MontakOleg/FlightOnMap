#import <MapKit/MapKit.h>

@interface MKPointAnnotation (ReuseId)
+ (NSString *)reuseId;
@end

@interface AirportAnnotation : MKPointAnnotation
- (instancetype)initWithTitle:(NSString *)title;
@end

@interface PlaneAnnotation : MKPointAnnotation
@end
