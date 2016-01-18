#import "MKMapView+Zoom.h"

@implementation MKMapView (Zoom)

- (MKZoomScale)mapZoomScale
{
    return self.bounds.size.width / self.visibleMapRect.size.width * 2;
}

@end
