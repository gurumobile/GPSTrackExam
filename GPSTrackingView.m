//
//  GPSTrackingView.m
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import "GPSTrackingView.h"

@implementation GPSTrackingView (fixPrivate)

- (void)initWithVars {
    self.backgroundColor = [UIColor clearColor];

    self.visitedPoints   = [[NSMutableArray alloc] init];
    self.superMapView    = nil;

    self.arrowThresold   = 0.0f; //50.0f; Default
}

- (UIImage *)imageNameNoCache:(NSString *)imageName {
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], imageName]];
}

@end

@implementation GPSTrackingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initWithVars];
    }
    return self;
}

#pragma mark -
#pragma mark - Draw Line and Arrow...

- (void)drawRect:(CGRect)rect {
    if ([_visitedPoints count] <= 1 || self.hidden) {
        return;
    }
    
    if (!self.superMapView) {
        self.superMapView = (MKMapView *)self.superview;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);

    CGPoint point;
    float distance = 0.0;
    
    int pointsCount = (int)[self.visitedPoints count];
    
    for (int i=0; i < pointsCount; i++) {
        float f = (float)i;
        CGContextSetRGBStrokeColor(context, 0, 1 - f / ( pointsCount - 1 ), f / ( pointsCount - 1), 0.8);
        
        CLLocation *nextLocation = [_visitedPoints objectAtIndex:i];
        
        point = [self.superMapView convertCoordinate:nextLocation.coordinate toPointToView:self];
        CGPoint lastPoint = point;
        
        if (i != 0) {
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(context, point.x, point.y);
            
            distance += sqrtf( pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2) );
            
            if (self.arrowThresold > 0.0f && distance >= _arrowThresold) {
                UIImage *image = _arrowImage;
                
                if (image != nil) {
                    CGPoint middle = CGPointMake((point.x + lastPoint.x) / 2,
                                                 (point.y + lastPoint.y) / 2);
                    CGRect frame = CGRectMake( ( middle.x - image.size.width / 2 ),
                                              ( middle.y - image.size.height / 2 ),
                                              image.size.width,
                                              image.size.height );
                    CGContextSaveGState(context);
                    CGContextTranslateCTM(context,
                                          frame.origin.x + frame.size.width / 2,
                                          frame.origin.y + frame.size.height / 2);
                    
                    float angle = atanf( ( point.y - lastPoint.y ) / ( point.x - lastPoint.x ) );
                    if (point.x < lastPoint.x) {
                        angle += 3.14159;
                    }
                    CGContextRotateCTM(context, angle);
                    CGContextDrawImage(context,
                                       CGRectMake(-frame.size.width / 2,
                                                  -frame.size.height / 2,
                                                  frame.size.width,
                                                  frame.size.height),
                                       image.CGImage);
                    CGContextRestoreGState(context);
                    distance = 0.0f;
                }
            }
        }
        CGContextStrokePath(context);
    }
}

- (void)addPoint:(CLLocation *)point {
    CLLocation *lastPoint = [_visitedPoints lastObject];

    if (point.coordinate.latitude != lastPoint.coordinate.latitude || point.coordinate.longitude != lastPoint.coordinate.longitude ) {
        [_visitedPoints addObject:point];
        
        [self setNeedsDisplay];
    }
}

- (CLLocation *)getLastLocation {
    return [_visitedPoints count] > 0 ? [_visitedPoints lastObject] : nil;
}

- (void)reset {
    [_visitedPoints removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.hidden = NO;
    [self setNeedsDisplay];
}

@end