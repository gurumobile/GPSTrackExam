//
//  ViewController.h
//  GPSTrackExam
//
//  Created by Bogdan Dimitrov Filov on 10/13/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPSTracker.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *outMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *outTrackingItem;
@property (weak, nonatomic) IBOutlet UILabel *outGPSSignalLbl;
@property (weak, nonatomic) IBOutlet UILabel *outSpeedLbl;

@property (nonatomic, strong) GPSTracker *gpsTracker;

- (void)resetGPSSignalStrength;

- (IBAction)onResetMap:(id)sender;
- (IBAction)onTracking:(id)sender;
- (IBAction)onSelectMapMode:(id)sender;
- (IBAction)onHasGPSSignal:(id)sender;

@end