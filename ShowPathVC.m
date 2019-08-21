//
//  ShowPathVC.m
//  Prova5
//
//  Created by Alessandro on 14/05/17.
//  Copyright © 2017 Alessandro. All rights reserved.
//

#import "ShowPathVC.h"
#import "DBManager.h"
#import "MapPoint.h"

@interface ShowPathVC ()

@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic) NSInteger indexOfDate;
@property (nonatomic) NSInteger indexOfDistance;
@property (nonatomic) NSInteger indexOfDuration;
@property (nonatomic) NSInteger indexOfMaxSpeed;
@property (nonatomic) NSInteger indexOfAvgSpeed;

@end

@implementation ShowPathVC

@synthesize selectedRow,dbManager,indexOfAvgSpeed,indexOfMaxSpeed,indexOfDuration,indexOfDistance,indexOfDate;

static NSString *const CSDataUpdatedNotification = @"PathUpdatedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:CSDataUpdatedNotification object:nil];
    
    self.dbManager = [[DBManager alloc] initWithDatabaseName:@"pathsdb.sql"];
    self.mapView.delegate = self;
    self.polyline = nil;
    [self.mapView setMapType:MKMapTypeStandard];
    
    [self loadIndex];
    [self loadPath];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadData{
    NSDateFormatter *getFormat = [[NSDateFormatter alloc] init];
    [getFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *setFormat = [[NSDateFormatter alloc] init];
    [setFormat setDateFormat:@"dd/MM/yyyy"];
    NSDateFormatter *durationFormat = [[NSDateFormatter alloc] init];
    [durationFormat setDateFormat:@"HH:mm:ss"];
    
    NSString *toChange = [selectedRow objectAtIndex:indexOfDate];
    NSDate *dateToChange = [getFormat dateFromString:toChange];
    
    _dateLabel.text = [NSString stringWithFormat:@"%@",[setFormat stringFromDate:dateToChange]];
    _timeLabel.text = [NSString stringWithFormat:@"%@",[durationFormat stringFromDate:dateToChange]];
    
    _avgSpeedLabel.text = [NSString stringWithFormat:@"%.2f Km/h",
                           [[selectedRow objectAtIndex:indexOfAvgSpeed] floatValue]];
    _maxSpeedLabel.text = [NSString stringWithFormat:@"%.2f Km/h",
                           [[selectedRow objectAtIndex:indexOfMaxSpeed] floatValue]];
    _durationLabel.text = [NSString stringWithFormat:@"%@",[selectedRow objectAtIndex:indexOfDuration]];
    _distanceLabel.text = [NSString stringWithFormat:@"%.2f Km",
                           [[selectedRow objectAtIndex:indexOfDistance] floatValue]];
    
}

-(void) loadIndex{
    [dbManager loadDataFromDB: @"select * from paths"];
    indexOfDate = [dbManager.arrColumnNames indexOfObject:@"date"];
    indexOfDistance = [dbManager.arrColumnNames indexOfObject:@"distance"];
    indexOfDuration = [dbManager.arrColumnNames indexOfObject:@"duration"];
    indexOfMaxSpeed = [dbManager.arrColumnNames indexOfObject:@"max_speed"];
    indexOfAvgSpeed = [dbManager.arrColumnNames indexOfObject:@"avg_speed"];
}

-(void) loadPath{
    NSString *query = [NSString stringWithFormat:@"select latitude,longitude from points where date='%@'", [selectedRow objectAtIndex:indexOfDate]];
    NSArray *points = [[NSArray alloc] initWithArray: [dbManager loadDataFromDB:query]];

    if(points.count > 1) {
        NSUInteger count = [points count];
        CLLocationCoordinate2D coordinates[count];
       
        for(NSInteger i=0;i<count;i++){
            double x = [points[i][0] doubleValue];;
            double y = [points[i][1] doubleValue];
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = x;
            coordinate.longitude = y;
            
            coordinates[i] = coordinate;
        }
        
        self.polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
        float paddingDIST=100;  //utile per centrare il percorso
        
        [self.mapView setVisibleMapRect: [self.polyline boundingMapRect]
            edgePadding:UIEdgeInsetsMake(paddingDIST, paddingDIST, paddingDIST, paddingDIST) animated:true];
        [self.mapView addOverlay:self.polyline];
        
        MapPoint *startPoint = [[MapPoint alloc] initWithCoordinates:coordinates[0] placeName:@"Partenza" description:@""];
        [self.mapView addAnnotation:startPoint];
        
        MapPoint *endPoint = [[MapPoint alloc] initWithCoordinates:coordinates[count-1] placeName:@"Arrivo" description:@""];
        [self.mapView addAnnotation:endPoint];
    }

}


/*questa funzione disegna il percorso sulla mappa*/
#pragma mark - MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        renderer.lineWidth = 5.0;
        return renderer;
    }
    return nil;
}
- (IBAction)deleteAction:(id)sender {
    NSString *query = [NSString stringWithFormat:@"delete from paths where date='%@'", [selectedRow objectAtIndex:indexOfDate]];
    [dbManager executeQuery:query];
    query = [NSString stringWithFormat:@"delete from points where date='%@'", [selectedRow objectAtIndex:indexOfDate]];
    [dbManager executeQuery:query];
    
    /*manda la notifia di "aggiornamento del database" alla schermata precedente */
    [[NSNotificationCenter defaultCenter] postNotificationName:CSDataUpdatedNotification object:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dataUpdated:(NSNotification *)notification{
    // Handle updates here
}

- (void)viewWillDisappear:(BOOL)animated{
    if(self.navigationController.viewControllers.count>1)
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
};
@end
