//
//  GPSTracker.h
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPSTrackingView.h"

typedef enum GPSSingalStrength {
    GPSSingalStrengthNone = 0,
    GPSSingalStrengthLow,
    GPSSingalStrengthMiddle,
    GPSSingalStrengthHigh,
    GPSSingalStrengthStrong,
    GPSSingalStrengthPerfect
} GPSSingalStrength;

typedef void (^GPSTrackerCompletionHandler)(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour);
typedef void (^GPSTrackerRealTimeHandler)(CGFloat meters, CGFloat seconds);
typedef void (^GPSTrackerInfoHandler)(CGFloat meters, CGFloat seconds, CLLocation *location);
typedef void (^GPSTrackerGpsSingalHandler)(BOOL hasSingal, GPSSingalStrength singalStrength, CLLocation *location);

@interface GPSTracker : NSObject <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIBarButtonItem *trackingItem;
@property (nonatomic, strong) UIBarButtonItem *resetItem;
@property (nonatomic, assign) BOOL isTracking;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) CLHeading *heading;

@property (nonatomic, strong) NSString *startTrackingTitle;
@property (nonatomic, strong) NSString *stopTrackingTitle;

@property (nonatomic, assign) CGFloat ranMeters;
@property (nonatomic, assign) CGFloat ranKilometers;
@property (nonatomic, assign) CGFloat ranMiles;
@property (nonatomic, assign) CGFloat ranSpeed;

@property (nonatomic, assign) CGFloat speedKilometersPerHour;
@property (nonatomic, assign) CGFloat speedMilesPerHour;

@property (nonatomic, assign) BOOL showCompletionAlert;

@property (nonatomic, strong) UIButton *headingButton;
@property (nonatomic, assign) CGFloat runningSeconds;

@property (nonatomic, copy) void (^changeHandler)(CGFloat meters, CGFloat seconds, CLLocation *location);
@property (nonatomic, copy) void (^realTimeHandler)(CGFloat meters, CGFloat seconds);
@property (nonatomic, copy) void (^headingHandler)(void);
@property (nonatomic, copy) void (^gpsSingalHandler)(BOOL hasSingal, GPSSingalStrength singalStrength, CLLocation *location);

@property (nonatomic, assign) BOOL isGpsNice;
@property (nonatomic, strong) UIImage *headingImage;
@property (nonatomic, assign) float arrowThresold;
@property (nonatomic, strong) UIImage *arrowImage;

+ (instancetype)sharedTracker;
- (void)initialize;
- (void)start;
- (void)initialStart;
- (void)stop;
- (void)stopTrackingWithCompletionHandler:(GPSTrackerCompletionHandler)_completionHandler;
- (void)resetMap;
- (void)selectMapMode:(MKMapType)selectedMapType;
- (BOOL)isMultitaskingSupported;
- (GPSSingalStrength)singalStrength;
- (GPSSingalStrength)singalStrengthWithLocation:(CLLocation *)location;
- (BOOL)hasGpsSingal;
- (BOOL)hasGpsSingalWithLocation:(CLLocation *)_location;
- (NSString *)catchCurrentGpsSingalStrengthString;
- (NSString *)catchLimitedGpsSingalStrengthStringWithLocation:(CLLocation *)_location;
- (BOOL)isGpsNiceSingalWithLocation:(CLLocation *)_location;

@end
