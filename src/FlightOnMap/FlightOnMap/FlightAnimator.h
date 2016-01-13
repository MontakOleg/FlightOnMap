#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlightAnimator : NSObject

@property (nonatomic, assign) NSTimeInterval animationDurationInSeconds;
@property (nonatomic, assign) CGSize airportSize;

@property (nonatomic, strong) NSString *startAirportName;
@property (nonatomic, strong) NSString *endAirportName;

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D endCoordinate;

- (instancetype)initWithMapView:(MKMapView *)mapView;

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay;

- (void)startFlight;
- (void)stopFlight;

@end
