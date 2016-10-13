//
//  ViewController.m
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _gpsTracker = [[GPSTracker alloc] init];
    _gpsTracker.mapView = _outMapView;
    _gpsTracker.trackingItem = _outTrackingItem;
    _gpsTracker.headingImage = [UIImage imageNamed:@"arrow_heading.png"];
    _gpsTracker.arrowImage = [UIImage imageNamed:@"arrow_2.png"];
    _gpsTracker.arrowThresold = 50.0f;
    
    [_gpsTracker initialize];
    
    //Block Method Using...
    __block UILabel *_speedTextLabel         = _outSpeedLbl;
    __block UILabel *_singalTextLabel        = _outGPSSignalLbl;
    __block GPSTracker *_blockKrGpsTracker = _gpsTracker;
    
    //This infoHandler Block will happen in location changed.
    [_gpsTracker setChangeHandler:^(CGFloat meters, CGFloat seconds, CLLocation *location)
     {
         NSLog(@"meter : %f, seconds : %f, location : %f, %f", meters, seconds, location.coordinate.latitude, location.coordinate.longitude);
         //You can use here to show the speed info when gps distance has changed.
         //Here is the advice of default.
         //Over 3 seconds then to start in show.
         if( seconds > 3.0f )
         {
             [_speedTextLabel setText:[NSString stringWithFormat:@"%.2f mi/h", _blockKrGpsTracker.speedMilesPerHour]];
         }
     }];
    
    //This realTimeHandler Block will happen in every second. ( 1 second to fire once. )
    [_gpsTracker setRealTimeHandler:^(CGFloat meters, CGFloat seconds)
     {
         NSLog(@"meter : %f, seconds : %f", meters, seconds);
         //You can use here to show the speed info by each second changing.
         if( seconds > 5.0f )
         {
             //[_speedTextLabel setText:[NSString stringWithFormat:@"%.2f mi/h", _blockKrGpsTracker.speedMilesPerHour]];
         }
     }];
    
    //This headingHandler Block will happen in your touching the heading-button on the left-top of map.
    [_gpsTracker setHeadingHandler:^
     {
         //NSLog(@"You Click the Heading-Button on the Map Left-Top.");
     }];
    
    //This gpsSingalHandler Block will happen with in the location keep in changing.
    [_gpsTracker setGpsSingalHandler:^(BOOL hasSingal, GPSSingalStrength singalStrength, CLLocation *location)
     {
         NSString *_singalText = [_blockKrGpsTracker catchLimitedGpsSingalStrengthStringWithLocation:location];
         [_singalTextLabel setText:_singalText];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - Methods...

- (IBAction)onResetMap:(id)sender {
    [_gpsTracker resetMap];
}

- (IBAction)onTracking:(id)sender {
    if (_gpsTracker.isTracking) {
        [_gpsTracker stopTrackingWithCompletionHandler:^(CGFloat ranMeters, CGFloat ranKilometers, CGFloat ranMiles, CGFloat speedKilometersPerHour, CGFloat speedMilesPerHour) {
            NSString *message = [NSString stringWithFormat:@"Distance : %.02f km, %.02f mi.\nSpeed: %.02f km/h, %.02f mi/h", ranKilometers, ranMiles, speedKilometersPerHour, speedMilesPerHour];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Route Info."
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Yes"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        }];
    }
    else
    {
        [_gpsTracker start];
    }
}

- (IBAction)onSelectMapMode:(id)sender {
    [_gpsTracker selectMapMode:[sender selectedSegmentIndex]];
}

- (IBAction)onHasGPSSignal:(id)sender {
    NSString *_singalSituation = @"";
    BOOL _hasGpsSingal = [_gpsTracker hasGpsSingal];
    
    if (_hasGpsSingal) {
        _singalSituation = @"Signal Alive.";
    } else {
        _singalSituation = @"Signal Disappear.";
    }
    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:@""
                                                         message:_singalSituation
                                                        delegate:nil
                                               cancelButtonTitle:@"Got It"
                                               otherButtonTitles:nil];
    [_alertView show];
}

- (void)resetGPSSignalStrength {
    [self.outGPSSignalLbl setText:[self.gpsTracker catchCurrentGpsSingalStrengthString]];
}


@end