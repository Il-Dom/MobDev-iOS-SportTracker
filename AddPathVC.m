//
//  AddPathVC.m
//  SportTracker
//
//  Created by Domenico Barretta on 06/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "AddPathVC.h"
#import "DBManager.h"

@interface AddPathVC()

@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) NSString *dateFormatted;
@property (nonatomic) BOOL initPosition;

@end

@implementation AddPathVC

@synthesize dbManager,locationArray,dateFormatted;

static NSString *const CSDataUpdatedNotification = @"PathUpdatedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:CSDataUpdatedNotification object:nil];
    
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [toolbarButtons removeObject:self.saveButton];
    [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    
    [self initView];
}

-(void) initView{
    if(locationArray!=nil){
        locationArray = nil;
    }
    
    //inizializzazione vista
    _timeElapse.text = @"00:00:00";
    _lblDistance.text = @"0.00 Km";
    _lblAvgSpeed.text = @"0.00 Km/h";
    _lblMaxSpeed.text = @"0.00 Km/h";
    _isRunning = false;
    _initPosition = true;
    
    //tempo di refresh della posizione
    _updateTime = 0.2;
    [_stopTimerCron invalidate];
    [_stopTimerSpeed invalidate];
    
    //inizializzazione del database
    self.dbManager = [[DBManager alloc]initWithDatabaseName:@"pathsdb.sql"];
    
    [self startLocationUpdates];
}


/* gestione posizione */
- (void) startLocationUpdates{
    if (self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    if([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager allowDeferredLocationUpdatesUntilTraveled:0 timeout:_updateTime];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    if(location != nil && _isRunning && location.horizontalAccuracy > 1) {
        
        if(self.locationArray.count > 0) {
            /*distanza tra due punti in metri*/
            _distance += [location distanceFromLocation: self.locationArray.lastObject];
        }
        NSString *query = [NSString stringWithFormat:@"insert into points values('%@',%f,%f)",
                           dateFormatted,location.coordinate.latitude,location.coordinate.longitude];
        [dbManager executeQuery:query];
        [self.locationArray addObject:location];
        
        NSUInteger count = [self.locationArray count];
        if(count>1){
            CLLocationCoordinate2D coordinates[count];
            for(NSInteger i=0;i<count;i++){
                coordinates[i] = [(CLLocation *)self.locationArray[i] coordinate];
            }
            
            MKPolyline *oldPolyline = self.polyline;
            self.polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
            [self.mapView addOverlay:self.polyline];
            
            if(oldPolyline)[self.mapView removeOverlay:oldPolyline];
        }
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 200, 200);
    if(_isRunning || _initPosition)[self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
        renderer.lineWidth = 5.0;
        return renderer;
    }
    return nil;
}

-(void)refreshLabel{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_start];
    _timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:_timerDate];
    
    _timeElapse.text = timeString;
    _lblDistance.text = [NSString stringWithFormat:@"%@", [self distanceToKm:_distance]];
    
    NSInteger count = self.locationArray.count;
    if (count>1){
        CLLocation *tmp = [self.locationArray objectAtIndex:count-1];
        float tmpSpeed = [tmp speed]*3.6;
        if(_maxSpeed < tmpSpeed){
            _maxSpeed = tmpSpeed;
            _lblMaxSpeed.text = [NSString stringWithFormat:@"%.2f Km/h", _maxSpeed];
        }
    }
}

-(void) updateAvgSpeed{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_start];
    _lblAvgSpeed.text = [NSString stringWithFormat:@"%@", [self avgSpeedFromDist:_distance overTime: timeInterval]];
}

- (NSString *)distanceToKm:(float)meters{
    return [NSString stringWithFormat:@"%.2f Km", (meters / 1000)];
}


- (NSString *)avgSpeedFromDist:(float)meters overTime:(float)seconds{
    if (seconds == 0 || meters == 0) {
        return @"0.00 Km/h";
    }
    _avgSpeed = (meters*3600) / (seconds*1000);
    return [NSString stringWithFormat:@"%.2f Km/h", _avgSpeed];
}

/*aggiunta dei punti al database*/
-(void) updatedbPath{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];

    NSString * query = [NSString stringWithFormat:@"insert into paths values('%@',%.2f,'%@',%.2f,%.2f)", dateFormatted,_distance/1000,[timeFormatter stringFromDate:_timerDate],_avgSpeed,_maxSpeed];
    [dbManager executeQuery:query];
}


/*gestione dei bottoni*/
- (IBAction)startAction:(id)sender {
    if(!_isRunning){
        _isRunning = TRUE;
        _distance = 0;
        _maxSpeed = 0;
        _start = [NSDate date];
        
        self.locationArray = [NSMutableArray array];
        
        NSDateFormatter *dateToString = [[NSDateFormatter alloc] init];
        [dateToString setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormatted = [dateToString stringFromDate:_start];
        
        _initPosition = false;
        [sender setTitle:@"Pausa" forState:UIControlStateNormal];
        if (_stopTimerCron == nil && _stopTimerSpeed == nil) {
            _stopTimerCron = [NSTimer scheduledTimerWithTimeInterval:_updateTime
                                                            target:self selector:@selector(refreshLabel) userInfo:nil repeats:YES];
            _stopTimerSpeed = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self selector:@selector(updateAvgSpeed) userInfo: nil repeats:YES];
        }
    }
    else{
        //stop corsa
        _isRunning = FALSE;
        [_stopTimerCron invalidate];
        [_stopTimerSpeed invalidate];
        float paddingDIST = 100.0;
        [self.mapView setVisibleMapRect: [self.polyline boundingMapRect]
                            edgePadding:UIEdgeInsetsMake(paddingDIST, paddingDIST, paddingDIST, paddingDIST) animated:true];
        [sender setEnabled:false];
        
        /*mostro bottone salvataggio*/
        NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (![toolbarButtons containsObject:self.saveButton]){
            [toolbarButtons addObject:self.saveButton];
            [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    /*se il percorso non viene salvato questa funzione elimina i punti e il percorso stesso dalla tabella*/
    if(_isRunning!=false && _initPosition!=false){
        NSString *query = [NSString stringWithFormat:@"delete from paths where date='%@'", dateFormatted];
        [dbManager executeQuery:query];
        query = [NSString stringWithFormat:@"delete from points where date='%@'", dateFormatted];
        [dbManager executeQuery:query];
    }
}

- (IBAction)saveAction:(id)sender {
    [self updatedbPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CSDataUpdatedNotification object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dataUpdated:(NSNotification *)notification{
    // Handle updates here
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
