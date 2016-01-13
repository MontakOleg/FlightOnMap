#include "Utils.h"

double distanceBetweenPoints(MKMapPoint point1, MKMapPoint point2)
{
    double dx = point2.x - point1.x;
    double dy = point2.y - point1.y;

    return sqrt(dx*dx + dy*dy);
}

CLLocationDirection directionBetweenPoints(MKMapPoint sourcePoint, MKMapPoint destinationPoint)
{
    double x = destinationPoint.x - sourcePoint.x;
    double y = destinationPoint.y - sourcePoint.y;
    
    return fmod(radiansToDegrees(atan2(y, x)), 360.0f);
}

double radiansToDegrees(double radians)
{
    return radians * 180.0f / M_PI;
}

double degreesToRadians(double degrees)
{
    return degrees * M_PI / 180.0f;
}
