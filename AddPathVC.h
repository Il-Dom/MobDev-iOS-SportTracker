//
//  AddPathVC.h
//  SportTracker
//
//  Created by Domenico Barretta on 06/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol AddPathVCDelegate <NSObject>
@required

@end

@interface AddPathVC : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>

/*per lo scambio di dati tra view*/
@property(nonatomic,retain) NSString *data;
@property(nonatomic,weak) id<AddPathVCDelegate> delegate;

/*per la mappa*/
@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline *polyline;
@property (nonatomic,strong) CLLocationManager *locationManager;
/**/

/*elementi dell'interfaccia*/
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *timeElapse;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxSpeed;
/**/

/*variabili utili per la corsa*/
@property (nonatomic) float distance;
@property (nonatomic) float actSpeed;
@property (nonatomic) float avgSpeed;
@property (nonatomic) float maxSpeed;
@property (nonatomic) NSDate *start;
@property (nonatomic) NSTimer *stopTimerSpeed;
@property (nonatomic) NSTimer *stopTimerCron;
@property (nonatomic) NSDate *timerDate;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) float updateTime;

- (NSString *)distanceToKm:(float)meters;
- (NSString *)avgSpeedFromDist:(float)meters overTime:(float)seconds;

@end
