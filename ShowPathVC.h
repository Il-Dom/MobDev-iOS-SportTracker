//
//  ShowPathVC.h
//  SportTracker
//
//  Created by Domenico Barretta on 14/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapKit/MapKit.h"

@interface ShowPathVC : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline *polyline;

@property (strong, nonatomic) NSArray *selectedRow;
@end
