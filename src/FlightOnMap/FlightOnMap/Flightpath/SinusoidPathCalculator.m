#import "SinusoidPathCalculator.h"
#import "Utils.h"

@interface SinusoidPathCalculator()
@property (nonatomic, assign) MKMapPoint startPoint;
@property (nonatomic, assign) MKMapPoint endPoint;
@end

@implementation SinusoidPathCalculator

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
{
    self = [super init];
    if (self) {
        self.startPoint = MKMapPointForCoordinate(startCoordinate);
        self.endPoint = MKMapPointForCoordinate(endCoordinate);
    }
    return self;
}

// pathPercent 0..1
- (MKMapPoint)pointForPathPercent:(double)pathPercent
{
    double distance = distanceBetweenPoints(self.startPoint, self.endPoint);
    double amplitude = distance / 10;

    double x = pathPercent * distance;
    double y = amplitude * sin(pathPercent * 2 * M_PI);

    // rotate and shift
    double angle = -1 * degreesToRadians(directionBetweenPoints(self.startPoint, self.endPoint)); // -1 to rotate clockwise

    double rx = self.startPoint.x + cos(angle) * x + sin(angle) * y;
    double ry = self.startPoint.y - sin(angle) * x  + cos(angle) * y;

    return MKMapPointMake(rx, ry);
}

- (MKPolyline *)createPolyline
{
    double distance = distanceBetweenPoints(self.startPoint, self.endPoint);
    NSUInteger numPoints = MAX(distance / 10000, 100);
    
    MKMapPoint *points = malloc(sizeof(MKMapPoint) * numPoints);
    for (int i = 0; i < numPoints; i++) {
        double pathPercent = (double)i / (numPoints - 1);
        points[i] = [self pointForPathPercent:pathPercent];
    }

    MKPolyline *polyline = [MKPolyline polylineWithPoints:points count:numPoints];
    free(points);
    return polyline;
}



@end
