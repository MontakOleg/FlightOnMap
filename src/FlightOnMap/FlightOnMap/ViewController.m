#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Utils.h"
#import "MapAnnotations.h"
#import "AirportAnnotationView.h"
#import "FlightPathRenderer.h"
#import "SinusoidPathCalculator.h"
#import "FlightAnimator.h"

// Rotation supported, but looks not perfect, so disabled by default
#define MAP_ROTATION_ENABLED NO

@interface ViewController ()<MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) FlightAnimator *flightAnimator;
@end


@implementation ViewController

- (void)loadView
{
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.rotateEnabled = MAP_ROTATION_ENABLED;
    self.view = self.mapView;
    
    [self addFlightAnimator];
}

- (void)addFlightAnimator
{
    self.flightAnimator = [[FlightAnimator alloc] initWithMapView:self.mapView];

    self.flightAnimator.startCoordinate = CLLocationCoordinate2DMake(61.702942, 25.582134);
    self.flightAnimator.startAirportName = @"LPP";
    
    self.flightAnimator.endCoordinate = CLLocationCoordinate2DMake(41.920323, 26.275076);
    self.flightAnimator.endAirportName = @"MUN";
    
    [self.flightAnimator startFlight];

    // Setup camera to airports
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    return [self.flightAnimator mapView:mapView rendererForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.flightAnimator mapView:mapView viewForAnnotation:annotation];
}

@end
