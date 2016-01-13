#import <MapKit/MapKit.h>

@interface AirportAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setTitle:(NSString *)title;

@end
