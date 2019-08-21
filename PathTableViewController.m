//
//  PathTableViewController.m
//  SportTracker
//
//  Created by Domenico Barretta on 04/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "PathTableViewController.h"
#import "AddPathVC.h"
#import "DBManager.h"
#import "PathViewCell.h"
#import "ShowPathVC.h"

@interface PathTableViewController ()

@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic,strong) NSArray *pathArray;
@property (nonatomic,weak) NSString *selectedRow;
@end

@implementation PathTableViewController
@synthesize pathArray,dbManager,selectedRow;

static NSString *const CSDataUpdatedNotification = @"PathUpdatedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:CSDataUpdatedNotification object:nil];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //inizializzo il dbManager
    self.dbManager = [[DBManager alloc] initWithDatabaseName:@"pathsdb.sql"];
    
    [dbManager executeQuery:@"create table if not exists paths(date datetime primary key, distance float, duration integer, avg_speed float, max_speed float)"];
    [dbManager executeQuery: @"create table if not exists points(date datetime references paths(date), latitude float, longitude float)"];
    
    //ricarico la tableview
    [self loadData];

    
}

- (void) loadData{
    NSString *query = @"select * from paths";
    if(pathArray!=nil){
        pathArray = nil;
    }
    NSArray *tmp = [[NSArray alloc] initWithArray: [dbManager loadDataFromDB:query]];
    pathArray = [[tmp reverseObjectEnumerator] allObjects];
    
    [self.tableView reloadData];
}

- (void)dataUpdated:(NSNotification *)notification{
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [pathArray count];
}


- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"pathIdentifier";
    
    PathViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger indexOfDate = [dbManager.arrColumnNames indexOfObject:@"date"];
    NSInteger indexOfDistance = [dbManager.arrColumnNames indexOfObject:@"distance"];
    NSInteger indexOfDuration = [dbManager.arrColumnNames indexOfObject:@"duration"];
    
    NSDateFormatter *getFormat = [[NSDateFormatter alloc] init];
    [getFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *setFormat = [[NSDateFormatter alloc] init];
    [setFormat setDateFormat:@"dd/MM/yy  HH:mm"];
    NSDateFormatter *durationFormat = [[NSDateFormatter alloc] init];
    [durationFormat setDateFormat:@"HH:mm:ss"];
    
    NSString *toChange = [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:indexOfDate];
    NSDate *dateToChange = [getFormat dateFromString:toChange];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",
                           [setFormat stringFromDate:dateToChange]];
    
    cell.durationLabel.text = [NSString stringWithFormat:@"%@",
                               [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:indexOfDuration]];
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%@ Km",
                               [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:indexOfDistance]];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowSegue"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        ShowPathVC *spVC = segue.destinationViewController;
        NSString *query = [NSString stringWithFormat: @"select * from paths where date='%@'",
                          [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:[dbManager.arrColumnNames indexOfObject:@"date"]]];
        spVC.selectedRow = [dbManager loadDataFromDB:query][0];
    }
}

- (IBAction)addPathButton:(id)sender {
    [self performSegueWithIdentifier:@"AddPathNCID" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
