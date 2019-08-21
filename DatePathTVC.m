//
//  DatePathTVC.m
//  SportTracker
//
//  Created by Domenico Barretta on 12/08/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "DatePathTVC.h"
#import "DBManager.h"
#import "PathViewCell.h"
#import "ShowPathVC.h"

@interface DatePathTVC ()

@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic,weak) NSString *selectedRow;

@end

@implementation DatePathTVC
@synthesize pathArray,dbManager,selectedRow,dateSelected;

static NSString *const CSDataUpdatedNotification = @"PathUpdatedNotification";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:CSDataUpdatedNotification object:nil];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.dbManager = [[DBManager alloc] initWithDatabaseName:@"pathsdb.sql"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dataUpdated:(NSNotification *)notification{
    
    NSString *query = [NSString stringWithFormat: @"select * from paths where date like '%@%%'",
    dateSelected];
    
    if(pathArray!=nil){
        pathArray = nil;
    }
    NSArray *tmp = [[NSArray alloc] initWithArray: [dbManager loadDataFromDB:query]];
    pathArray = [[tmp reverseObjectEnumerator] allObjects];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pathArray count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath{
    
    self.navigationItem.title = dateSelected;
    static NSString *CellIdentifier = @"datePath";
    
    PathViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *getFormat = [[NSDateFormatter alloc] init];
    [getFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *setFormat = [[NSDateFormatter alloc] init];
    [setFormat setDateFormat:@"HH:mm"];
    NSDateFormatter *durationFormat = [[NSDateFormatter alloc] init];
    [durationFormat setDateFormat:@"HH:mm:ss"];
    
    NSString *toChange = [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:0];
    NSDate *dateToChange = [getFormat dateFromString:toChange];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", [setFormat stringFromDate:dateToChange]];
    cell.durationLabel.text = [NSString stringWithFormat:@"%@", [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:2]];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%@ Km", [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:1]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowDate"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        ShowPathVC *spVC = segue.destinationViewController;
        NSString *query = [NSString stringWithFormat: @"select * from paths where date='%@'",
                           [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:0]];
        NSLog(@"%@", [[self.pathArray objectAtIndex:indexPath.row] objectAtIndex:0]);
        spVC.selectedRow = [dbManager loadDataFromDB:query][0];
    }
}

@end
