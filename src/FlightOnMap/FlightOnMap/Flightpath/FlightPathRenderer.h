#import <MapKit/MapKit.h>

@interface FlightPathRenderer : MKOverlayRenderer

@property (nonatomic, assign) CGSize airportSize;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *pointColor;

- (instancetype)initWithPolyline:(MKPolyline *)polyline;

- (MKPolyline *)polyline;

@end