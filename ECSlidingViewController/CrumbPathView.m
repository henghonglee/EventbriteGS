
#import "CrumbPathView.h"
#import "CrumbObj.h"
#import "CrumbPath.h"

@interface CrumbPathView (FileInternal)
- (CGPathRef)newPathForPoints:(MKMapPoint *)points
                      pointCount:(NSUInteger)pointCount
                        clipRect:(MKMapRect)mapRect
                       zoomScale:(MKZoomScale)zoomScale;
@end

@implementation CrumbPathView

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{

    CrumbPath *crumbs = (CrumbPath *)(self.overlay);
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);
    [crumbs lockForReading];
    MKMapPoint point;
    NSUInteger i;
    for (i = 0; i < crumbs.pointCount; i++)
    {
        point = crumbs.points[i];
        CGPoint lastCGPoint = [self pointForMapPoint:point];
        
        if (MKMapRectContainsPoint(mapRect, point))
        {
//            UIImage* circleImage = [UIImage imageNamed:@"buttonOrange@2x.png"];
//            CGContextDrawImage(context, (CGRectMake (lastCGPoint.x-lineWidth/2, lastCGPoint.y-lineWidth/2, lineWidth, lineWidth )), circleImage.CGImage);
//            CGContextSetFillColorWithColor(context, ((CrumbObj*)[crumbs.pointsArray objectAtIndex:i]).pointColor.CGColor); // Or any other color.
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillEllipseInRect(context, (CGRectMake (lastCGPoint.x-lineWidth/4, lastCGPoint.y-lineWidth/4, lineWidth/2, lineWidth/2 )));
            
            CGContextAddEllipseInRect(context, (CGRectMake (lastCGPoint.x-lineWidth/4, lastCGPoint.y-lineWidth/4, lineWidth/2, lineWidth/2 )));
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 2);
            CGContextStrokePath(context);
        }
    }

    [crumbs unlockForReading];
}

@end

@implementation CrumbPathView (FileInternal)

static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

#define MIN_POINT_DELTA 5.0

- (CGPathRef)newPathForPoints:(MKMapPoint *)points
                      pointCount:(NSUInteger)pointCount
                        clipRect:(MKMapRect)mapRect
                       zoomScale:(MKZoomScale)zoomScale
{
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.  
    // While it is possible to just add all the points and let CoreGraphics 
    // handle clipping and flatness, it is much faster to do it yourself:
    //
    if (pointCount < 2)
        return NULL;
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
#define POW2(a) ((a) * (a))
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);
    
    MKMapPoint point, lastPoint = points[0];
    NSUInteger i;
    for (i = 1; i < pointCount - 1; i++)
    {
        point = points[i];
        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point, lastPoint, mapRect))
            {
                if (!path) 
                    path = CGPathCreateMutable();
                if (needsMove)
                {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
            }
            else
            {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            lastPoint = point;
        }
    }
    
#undef POW2
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
    if (lineIntersectsRect(lastPoint, point, mapRect))
    {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove)
        {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

@end
