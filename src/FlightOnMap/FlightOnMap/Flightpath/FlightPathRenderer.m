
#import "FlightPathRenderer.h"
#import "Utils.h"
#import "MKMapView+Zoom.h"

@interface FlightPathRenderer()
@property (nonatomic, strong) MKPolyline *polyline;
@end

@implementation FlightPathRenderer

- (instancetype)initWithPolyline:(MKPolyline *)polyline
{
    self = [super initWithOverlay:polyline];
    if (self) {
        self.polyline = polyline;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)dontUseMeUseAccurateZoomScaleInstead
          inContext:(CGContextRef)context
{
    NSUInteger pointCount = self.polyline.pointCount;
    MKMapPoint *points = self.polyline.points;

    // drawMapRect: method always reflects the current zoom level.
    // We need calculate realZoom to improve rendering
    //
    MKZoomScale accurateZoomScale = [self.mapView mapZoomScale];
    
    // Clip map to avoid clipping points on borders of mapRect
    //
    CGFloat lineSize = self.lineWidth / accurateZoomScale;
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineSize, -lineSize);

    if (pointCount > 1)
    {
        CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
        
        const double MIN_POINT_DELTA = 20.0;
        double minPointDelta = MIN_POINT_DELTA / accurateZoomScale;

        // We dont want draw path points on airports. Airport rects extended to lineZise to avoid
        // drawing points on airport borders.
        //
        MKMapRect startAirportRect = MakeRectWithCenterPoint(points[0], self.airportSize.width, self.airportSize.height, accurateZoomScale);
        startAirportRect = MKMapRectInset(startAirportRect, -lineSize, -lineSize);
        
        MKMapRect endAirportRect = MakeRectWithCenterPoint(points[pointCount-1], self.airportSize.width, self.airportSize.height, accurateZoomScale);
        endAirportRect = MKMapRectInset(endAirportRect, -lineSize, -lineSize);

        MKMapPoint lastPoint = points[0];
        for (NSUInteger index = 0; index < pointCount; index++) {
            MKMapPoint point = points[index];
            double pointDelta = distanceBetweenPoints(point, lastPoint);
            if (pointDelta >= minPointDelta || index == 0) {
                
                BOOL pointIntersectsWithAirport = MKMapRectContainsPoint(startAirportRect, point) ||
                                                  MKMapRectContainsPoint(endAirportRect, point);

                if (MKMapRectContainsPoint(clipRect, point) &&
                    !pointIntersectsWithAirport) {
                    
                    CGPoint cgPoint = [self pointForMapPoint:point];
                    CGContextFillEllipseInRect(context, CGRectMake(cgPoint.x - lineSize / 2, cgPoint.y - lineSize / 2, lineSize, lineSize));

                }
                lastPoint = point;
            }
        }
    }
}

static MKMapRect MakeRectWithCenterPoint(MKMapPoint centerPoint, double width, double height, double zoomScale)
{
    double deviceScale = [UIScreen mainScreen].scale;
    double scaledWidth = width * deviceScale / zoomScale;
    double scaledHeight = height * deviceScale / zoomScale;

    MKMapRect rect = MKMapRectMake(centerPoint.x - scaledWidth / 2.0, centerPoint.y - scaledHeight / 2.0, scaledWidth, scaledHeight);
    return rect;
}

@end