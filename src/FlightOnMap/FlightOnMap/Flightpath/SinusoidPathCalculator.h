#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SinusoidPathCalculator : NSObject

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate;

- (MKMapPoint)pointForPathPercent:(double)pathPercent;

- (MKPolyline *)createPolyline;

@end
