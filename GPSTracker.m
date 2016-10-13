//
//  GPSTracker.m
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import "GPSTracker.h"

@interface GPSTracker ()

@property (nonatomic, strong) GPSTrackingView *trackingMapView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat keepTime;

@end

@implementation GPSTracker (fixPrivate)

- (void)initWithVars {
    self.startTrackingTitle     = @"Start Tracking";
    self.stopTrackingTitle      = @"Stop Tracking";
    self.ranMeters              = 0.0f;
    self.ranMiles               = 0.0f;
    self.ranKilometers          = 0.0f;
    self.speedKilometersPerHour = 0.0f;
    self.speedMilesPerHour      = 0.0f;
    self.showCompletionAlert    = NO;
    self.headingButton          = nil;
    self.runningSeconds         = 0.0f;
    self.changeHandler          = nil;
    self.headingHandler         = nil;
    self.timer                  = nil;
    self.keepTime               = 0.0f;
    self.arrowThresold          = 0.0f;
}

- (void)remove {
    self.isTracking  = NO;
    if (self.trackingMapView) {
        [self.trackingMapView removeFromSuperview];
        self.trackingMapView = nil;
    }
}

- (UIImage *)imageNoCacheWithName:(NSString *)imageName {
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], imageName]];
}

- (void)headingButtonAction:(id)sender {
    if (self.headingHandler) {
        self.headingHandler();
    }
}

- (void)makeHeadingIconButton {
    if (self.headingButton) {
        if (self.headingButton.superview == self.mapView) {
            [self.headingButton removeFromSuperview];
        }
    }
    UIImage *image = self.headingImage;
    self.headingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.headingButton setFrame:CGRectMake(5.0f, 5.0f, image.size.width, image.size.height)];
    [self.headingButton setImage:image forState:UIControlStateNormal];
    [self.headingButton addTarget:self
                           action:@selector(headingButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.headingButton];
}

#pragma mark -
#pragma mark - NSTimer...

- (void)keepCounting {
    ++self.keepTime;
    
    if (self.realTimeHandler) {
        self.realTimeHandler(self.ranMeters, self.keepTime);
    }
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(keepCounting) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.keepTime  = 0.0f;
}

@end

@implementation GPSTracker

+ (instancetype)sharedTracker {
    static dispatch_once_t pred;
    static GPSTracker *singleton = nil;
    dispatch_once(&pred, ^{
        singleton = [[GPSTracker alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initWithVars];
    }
    return self;
}

#pragma mark -
#pragma mark - Initialize Method...

- (void)initialize {
    [self remove];
    _trackingMapView = [[GPSTrackingView alloc] initWithFrame:_mapView.frame];
    _trackingMapView.superMapView = _mapView;
    _trackingMapView.arrowThresold = _arrowThresold;
    _trackingMapView.arrowImage = _arrowImage;
    
    [[[_mapView subviews] objectAtIndex:0] addSubview:_trackingMapView];
    
    [self makeHeadingIconButton];

    _mapView.delegate = _trackingMapView;
    
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.showsUserLocation = YES;
    _locationManager = [[CLLocationManager alloc] init];
    
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    _locationManager.delegate  = self;
}

- (void)start {
    if (!_isTracking) {
        _isTracking = YES;
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled   = NO;

        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        _trackingItem.title = _stopTrackingTitle;
        _ranMeters = 0.0f;

        _startDate = [NSDate date];

        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
        _locationManager.distanceFilter = 10.0f;
        _locationManager.headingFilter  = kCLHeadingFilterNone;
        [_locationManager startUpdatingHeading];

        [self startTimer];
    }
}

- (void)initialStart {
    [self initialize];
    [self start];
}

- (void)stop {
    [self stopTimer];
    _isTracking = NO;

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _trackingItem.title = _startTrackingTitle;
    
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];

    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    CGFloat _time = _runningSeconds;
    _ranKilometers = _ranMeters / 1000;
    _ranMiles = _ranMeters * 0.00062f;
    _speedKilometersPerHour = _ranMeters * 3.6f / _time;
    _speedMilesPerHour = _ranMeters * 2.2369f / _time;
}

- (void)stopTrackingWithCompletionHandler:(GPSTrackerCompletionHandler)completionHandler {
    if (_isTracking) {
        [self stop];
        if (completionHandler) {
            completionHandler(self.ranMeters, self.ranKilometers, self.ranMiles, self.speedKilometersPerHour, self.speedMilesPerHour);
        }
        if (_showCompletionAlert) {
            NSString *_message = [NSString stringWithFormat:@"Distance : %.02f km, %.02f mi.\nSpeed: %.02f km/h, %.02f mi/h",
                                  self.ranKilometers,
                                  self.ranMiles,
                                  self.speedKilometersPerHour,
                                  self.speedMilesPerHour];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Route Info."
                                                                message:_message
                                                               delegate:self
                                                      cancelButtonTitle:@"Yes"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        }
    }
}

- (void)resetMap {
    [_trackingMapView reset];
}

- (void)selectMapMode:(MKMapType)selectedMapType {
    switch (selectedMapType) {
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (BOOL)isMultitaskingSupported {
    return ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) ? [[UIDevice currentDevice] isMultitaskingSupported] : NO;
}

- (GPSSingalStrength)singalStrength {
    return [self singalStrengthWithLocation:self.locationManager.location];
}

- (GPSSingalStrength)singalStrengthWithLocation:(CLLocation *)location {
    CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;
    GPSSingalStrength singalStrength = GPSSingalStrengthNone;
    
    if ((horizontalAccuracy > 0.0f) && (horizontalAccuracy <= 10.0f)) {
        singalStrength = GPSSingalStrengthPerfect;
    } else if ((horizontalAccuracy > 10.0f) && (horizontalAccuracy <= 30.0f)) {
        singalStrength = GPSSingalStrengthStrong;
    } else if ((horizontalAccuracy > 30.0f) && (horizontalAccuracy <= 60.0f)) {
        singalStrength = GPSSingalStrengthHigh;
    } else if ((horizontalAccuracy > 60.0f ) && (horizontalAccuracy <= 100.0f)) {
        singalStrength = GPSSingalStrengthMiddle;
    } else if ((horizontalAccuracy > 100.0f) && (horizontalAccuracy <= 200.0f)) {
        singalStrength = GPSSingalStrengthLow;
    }
    return singalStrength;
}

- (BOOL)hasGpsSingal {
    return !([self singalStrength] == GPSSingalStrengthNone );
}

- (BOOL)hasGpsSingalWithLocation:(CLLocation *)location {
    return !([self singalStrengthWithLocation:location] == GPSSingalStrengthNone );
}

- (NSString *)catchCurrentGpsSingalStrengthString {
    return [self catchLimitedGpsSingalStrengthStringWithLocation:self.locationManager.location];
}

- (NSString *)catchLimitedGpsSingalStrengthStringWithLocation:(CLLocation *)location {
    NSString *_gpsSingalString = @"No Singal";
    switch ([self singalStrengthWithLocation:location]) {
        case GPSSingalStrengthNone:
            //No Singal.
            break;
        case GPSSingalStrengthLow:
            //Low Singal.
            _gpsSingalString = @"Low Singal";
            break;
        case GPSSingalStrengthMiddle:
            //Middle Singal.
            _gpsSingalString = @"Middle Singal";
            break;
        case GPSSingalStrengthHigh:
            //High Singal.
            _gpsSingalString = @"High Singal";
            break;
        case GPSSingalStrengthStrong:
            //Strong Singal.
            _gpsSingalString = @"Strong Singal";
            break;
        case GPSSingalStrengthPerfect:
            //Perfect Singal. ( Almost Impossible )
            _gpsSingalString = @"Perfect Singal";
            break;
        default:
            break;
    }
    return _gpsSingalString;
}

- (BOOL)isGpsNiceSingalWithLocation:(CLLocation *)location {
    return (location.horizontalAccuracy <= 100.0f);
}

#pragma mark -
#pragma mark - MapViewDelegate...

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

#pragma mark -
#pragma makr - CLLocationManagerDelegate...

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation = [_trackingMapView getLastLocation];
    
    [_trackingMapView addPoint:newLocation];

    if (nil != oldLocation) {
        _ranMeters += [newLocation distanceFromLocation:oldLocation];
    }
    
    if (_changeHandler) {
        self.changeHandler(_ranMeters, self.runningSeconds, newLocation);
    }
    
    if (_gpsSingalHandler) {
        self.gpsSingalHandler( [self hasGpsSingal], [self singalStrength], newLocation );
    }

    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
    
    [_mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    float rotation = newHeading.trueHeading * M_PI / 180;

    if (_headingButton) {
        _headingButton.transform = CGAffineTransformIdentity;
        CGAffineTransform transForm = CGAffineTransformMakeRotation(-rotation);
        _headingButton.transform = transForm;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stop];
}

#pragma mark -
#pragma mark - Monitorings...

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

#pragma mark -
#pragma mark - Getter...

- (CGFloat)ranKilometers {
    return _ranMeters / 1000;
}

- (CGFloat)ranMiles {
    return _ranMeters * 0.00062f;
}

- (CGFloat)speedKilometersPerHour {
    return _ranMeters * 3.6f / self.runningSeconds;
}

- (CGFloat)speedMilesPerHour {
    return _ranMeters * 2.2369f / self.runningSeconds;
}

- (CGFloat)runningSeconds {
    return -[_startDate timeIntervalSinceNow];
}

- (BOOL)isGpsNice {
    return (_locationManager.location.horizontalAccuracy <= 100.0f);
}

@end
