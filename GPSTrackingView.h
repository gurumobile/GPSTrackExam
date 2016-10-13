//
//  GPSTrackingView.h
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GPSTrackingView : UIView <MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *visitedPoints;
@property (nonatomic, strong) MKMapView *superMapView;
@property (nonatomic, assign) CGFloat arrowThresold;
@property (nonatomic, strong) UIImage *arrowImage;

- (void)addPoint:(CLLocation *)point;
- (CLLocation *)getLastLocation;

- (void)reset;

@end
