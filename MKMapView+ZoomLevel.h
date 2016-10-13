//
//  MKMapView+ZoomLevel.h
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(double)zoomLevel
                   animated:(BOOL)animated;

- (double)getZoomLevel;

@end
