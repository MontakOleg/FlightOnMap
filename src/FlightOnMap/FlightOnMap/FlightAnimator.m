#import "FlightAnimator.h"
#import "MapAnnotations.h"
#import "SinusoidPathCalculator.h"
#import "AirportAnnotationView.h"
#import "FlightPathRenderer.h"
#import "Utils.h"

#define DEFAULT_ANIMATION_DURATION_IN_SECONDS 15

#define AIRPORT_WIDTH 65
#define AIRPORT_HEIGHT 35

@interface FlightAnimator ()
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) AirportAnnotation *startAirportAnnotation;
@property (nonatomic, strong) AirportAnnotation *endAirportAnnotation;

@property (nonatomic, strong) MKPointAnnotation *planeAnnotation;
@property (nonatomic, strong) MKAnnotationView *planeView;

@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, assign) NSTimeInterval flightTime;

@property (nonatomic, strong) MKPolyline *flightPathPolyline;
@property (nonatomic, strong) SinusoidPathCalculator *pathCalculator;

@property (nonatomic, strong) FlightPathRenderer *flightPathRenderer;
@end

@implementation FlightAnimator

- (instancetype)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        
        self.animationDurationInSeconds = DEFAULT_ANIMATION_DURATION_IN_SECONDS;
        self.airportSize = CGSizeMake(AIRPORT_WIDTH, AIRPORT_HEIGHT);
    }
    return self;
}

- (void)startFlight
{
    [self stopFlight];
    
    self.pathCalculator = [[SinusoidPathCalculator alloc] initWithStartCoordinate:self.startCoordinate endCoordinate:self.endCoordinate];
    self.flightPathPolyline = [self.pathCalculator createPolyline];

    self.flightPathRenderer = [self createFlightPathRendererForPath:self.flightPathPolyline];
    [self setupMap];
    
    self.flightTime = 0;
    self.lastTimestamp = 0;
    
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (FlightPathRenderer *)createFlightPathRendererForPath:(MKPolyline *)flightPath
{
    FlightPathRenderer *renderer = [[FlightPathRenderer alloc] initWithPolyline:flightPath];
    renderer.airportSize = self.airportSize;
    
    renderer.lineWidth = 8.0f;
    renderer.pointColor = [UIColor colorWithWhite:0 alpha:0.5];

    renderer.mapView = self.mapView;
    
    return renderer;
}

- (void)stopFlight
{
    [self.timer removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.timer = nil;
    
    [self.mapView removeOverlay:self.flightPathPolyline];
    self.flightPathPolyline = nil;
    self.flightPathRenderer = nil;
    
    [self.mapView removeAnnotation:self.startAirportAnnotation];
    self.startAirportAnnotation = nil;
    
    [self.mapView removeAnnotation:self.endAirportAnnotation];
    self.endAirportAnnotation = nil;
    
    [self.mapView removeAnnotation:self.planeAnnotation];
    self.planeAnnotation = nil;
}

- (void)setupMap
{
    // Add path
    [self.mapView addOverlay:self.flightPathPolyline];
    
    // Add airports
    self.startAirportAnnotation = [[AirportAnnotation alloc] initWithTitle:self.startAirportName];
    self.startAirportAnnotation.coordinate = self.startCoordinate;
    [self.mapView addAnnotation:self.startAirportAnnotation];
    
    self.endAirportAnnotation = [[AirportAnnotation alloc] initWithTitle:self.endAirportName];
    self.endAirportAnnotation.coordinate = self.endCoordinate;
    [self.mapView addAnnotation:self.endAirportAnnotation];
    
    // Add plane
    self.planeAnnotation = [[PlaneAnnotation alloc] init];
    self.planeAnnotation.coordinate = self.startCoordinate;
    [self.mapView addAnnotation:self.planeAnnotation];
}

- (void)tick:(CADisplayLink *)sender
{
    if (self.lastTimestamp == 0) {
        // first tick, nothing to do
        self.lastTimestamp = sender.timestamp;
        return;
    }
    
    CFTimeInterval elapsedTime = sender.timestamp - self.lastTimestamp;
    self.lastTimestamp = sender.timestamp;
    
    [self updatePlanePositionWithElapsedTime:elapsedTime];
}

- (void)updatePlanePositionWithElapsedTime:(NSTimeInterval)elapsedTime
{
    self.flightTime += elapsedTime;
    if (self.flightTime > self.animationDurationInSeconds) {
        // Start flight again
        self.flightTime = 0;
    }
    
    MKMapPoint prevPoint = MKMapPointForCoordinate(self.planeAnnotation.coordinate);
    MKMapPoint nextPoint = [self mapPointForFlightTime:self.flightTime];
    CLLocationDirection direction = directionBetweenPoints(prevPoint, nextPoint) - self.mapView.camera.heading;
    
    self.planeView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, degreesToRadians(direction));
    self.planeAnnotation.coordinate = MKCoordinateForMapPoint(nextPoint);
}

- (MKMapPoint)mapPointForFlightTime:(NSTimeInterval)flightTime
{
    double relativeFlightTime = flightTime / self.animationDurationInSeconds;
    return [self.pathCalculator pointForPathPercent:relativeFlightTime];
}

#pragma mark - MKMapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == self.planeAnnotation) {
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:[annotation.class reuseId]];
        if (!view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation.class reuseId]];
            
            UIImage *image = [UIImage imageNamed:@"plane"];
            view.image = image;
            view.bounds = CGRectMake(0, 0, 32, 32);
            view.alpha = 0.8;
        }

        view.annotation = annotation;
        self.planeView = view;
        return view;
    }
    
    if (annotation == self.startAirportAnnotation || annotation == self.endAirportAnnotation) {
        
        AirportAnnotationView *view = (AirportAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:[annotation.class reuseId]];
        if (!view) {
            view = [[AirportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation.class reuseId]];
            view.bounds = CGRectMake(0, 0, self.airportSize.width, self.airportSize.height);
        }
        view.annotation = annotation;
        [view setTitle:annotation.title];
        return view;
    }
    
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if (overlay != self.flightPathPolyline) {
        return nil;
    }
    
    return self.flightPathRenderer;
}

- (void)invalidateFlightPath
{
    [self.flightPathRenderer setNeedsDisplayInMapRect:self.mapView.visibleMapRect];
}


@end
