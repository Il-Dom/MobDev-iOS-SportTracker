//
//  CalendarVC.m
//  SportTracker
//
//  Created by Domenico Barretta on 09/07/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "CalendarVC.h"
#import "DBManager.h"
#import "ShowPathVC.h"
#import "DatePathTVC.h"
#import <QuartzCore/QuartzCore.h>

@interface CalendarVC ()

@property (nonatomic,strong) DBManager *dbManager;
@property (nonatomic,strong) NSArray *pathArray;

@end

static NSString *const CSDataUpdatedNotification = @"PathUpdatedNotification";

NSUInteger numDays;
int currYear;
int firstDay;
int currMonth;

@implementation CalendarVC
@synthesize Month,pathArray,dbManager,queryResult,selectedDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dbManager = [[DBManager alloc] initWithDatabaseName:@"pathsdb.sql"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:CSDataUpdatedNotification object:nil];
    
    [self createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataUpdated:(NSNotification *)notification{
    // Handle updates here
    [self createView];
}

- (IBAction)prevAction:(id)sender {
    currMonth--;
    _nextMonth.hidden = false;
    
    [self removeTags];
    [self updateCal];
}

- (IBAction)todayAction:(id)sender {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSCalendarUnitMonth fromDate:[NSDate date]];
    
    currMonth=(int)[comp month];
    _nextMonth.hidden = true;
    [self removeTags];
    [self updateCal];
}

- (IBAction)nextAction:(id)sender {
    currMonth++;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSCalendarUnitMonth fromDate:[NSDate date]];
    if(currMonth == (int)[comp month] &&
       currYear == (int)[[[NSCalendar currentCalendar]components: NSCalendarUnitYear fromDate:[NSDate date]] year]){
        _nextMonth.hidden = true;
    }
    
    [self removeTags];
    [self updateCal];
}

- (void) removeTags{
    for (int x=1; x<=31 ;x++){
        [[self.view viewWithTag:x] removeFromSuperview];
    }
}

- (NSUInteger) getCurrDate: (NSDate *)currDate{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange dim = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currDate];
    NSUInteger numberOfDays = dim.length;
    
    return numberOfDays;
}

-(void) createView{
    _nextMonth.hidden = true;
    currYear = (int)[[[NSCalendar currentCalendar]
                 components: NSCalendarUnitYear fromDate:[NSDate date]] year];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSCalendarUnitMonth fromDate:[NSDate date]];
    currMonth = (int)[comp month];
    
    NSString *query = @"select * from paths";
    if(pathArray != nil) pathArray=nil;
    NSArray *tmp = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    pathArray = [[tmp reverseObjectEnumerator] allObjects];
    
    [self getDate];
}

-(void) updateCal{
    if(currMonth>12){
        currMonth=1;
        currYear++;
    }
    if (currMonth<1){
        currMonth=12;
        currYear--;
    }
    
    [self getDate];
}

-(void) getDate{
    NSCalendar *gregorian=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //trovo il primo giorno del mese
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *comps=[[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:currMonth];
    [comps setYear:currYear];
    
    NSDate *newDate=[calendar dateFromComponents:comps];
    NSDateComponents *comps2=[gregorian components:NSCalendarUnitWeekday fromDate:newDate];
    firstDay = (int)[comps2 weekday]-1;    //prendo numero giorni del mese
    if(firstDay ==0) firstDay=7;
    
    numDays=[self getCurrDate:newDate];
    int yVal =145;
    int yCount=1;
    int cellSize = ([UIScreen mainScreen].bounds.size.width-30)/7;
    
    Month.text = [self returnMonth:currMonth];

    for (int i=1;i<=numDays;i++){
        
        /*bottone del giorno*/
        UIButton *addButton=[UIButton buttonWithType: UIButtonTypeRoundedRect];
        int xPos = (firstDay*cellSize)-cellSize+15;
        int yPos = (yCount*cellSize)+yVal;
        
        firstDay++;
        if(firstDay>7){
            firstDay=1;
            yCount++;
        }
        
        addButton.frame = CGRectMake(xPos,yPos,cellSize,cellSize);
        [addButton setTitle:[NSString stringWithFormat:@"%d",i]forState:UIControlStateNormal];
        addButton.layer.borderWidth=0.5f;
        addButton.layer.borderColor=[UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1.0].CGColor;
    
        /* Verifico se nel mese corrente è stata effettuata una corsa.
         Creo una data fittizia per ogni giorno del mese e successivamente la converto
         in stringa, in modo da tenere il formato yyyy-mm-dd (altrimenti i giorni e i mesi
         ad una sola cifra avrebbero il formato yyyy-m-d)
        */
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateFormatted = [NSString stringWithFormat:@"%d-%d-%d", currYear, currMonth, i];
        NSDate *date  = [dateFormatter dateFromString:dateFormatted];
        
        NSInteger indexOfDate = [dbManager.arrColumnNames indexOfObject:@"date"];
        bool found=false;
        for(int row=0;row<[pathArray count];row++){
            NSString *dateToCheck = [[self.pathArray objectAtIndex:row] objectAtIndex:indexOfDate];
            if([dateToCheck containsString:[dateFormatter stringFromDate:date]])found=true;
        }
        addButton.tag = i; //mi serve per sapere che bottone sto tappando
        if(found){  //se trovo una data mostro la relativa schermata 
            addButton.backgroundColor=[UIColor redColor];
            [addButton addTarget:self action:@selector(showPath:)forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            addButton.backgroundColor=[UIColor whiteColor];
            [addButton addTarget:self action:@selector(emptyPath:)forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:addButton];
    }
}

-(void)showPath:(UIButton *)sender{
    int index = (int)sender.tag;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateFormatted = [NSString stringWithFormat:@"%d-%d-%d", currYear, currMonth, index];
    selectedDate  = [dateFormatter dateFromString:dateFormatted];
    
    NSString *query = [NSString stringWithFormat: @"select * from paths where date like '%@%%'", [dateFormatter stringFromDate:selectedDate]];
    queryResult = [[NSArray alloc] initWithArray: [dbManager loadDataFromDB:query]];
    
    if(queryResult.count==1) {
        [self performSegueWithIdentifier:@"ShowSinglePath" sender:sender];
    }
    else {
        [self performSegueWithIdentifier:@"ShowMultiplePaths" sender:sender];
    }
}

- (void)emptyPath:(UIButton *)sender{
    [self performSegueWithIdentifier:@"EmptySegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender{
    if ([segue.identifier isEqualToString:@"ShowSinglePath"]){
        ShowPathVC *spVC = segue.destinationViewController;
        spVC.selectedRow = queryResult[0];
    }
    else if([segue.identifier isEqualToString:@"ShowMultiplePaths"]){
        DatePathTVC *dpTVC = segue.destinationViewController;
        dpTVC.pathArray = queryResult;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        dpTVC.dateSelected = [NSString stringWithFormat:@"%ld %@",(long)sender.tag,[self returnMonth:currMonth]];
    }
}

-(NSString *)returnMonth:(int) currMon{
    switch (currMon-1) {
        case 0:
            return @"Gennaio";
            break;
        case 1:
            return @"Febbraio";
            break;
        case 2:
            return @"Marzo";
            break;
        case 3:
            return @"Aprile";
            break;
        case 4:
            return @"Maggio";
            break;
        case 5:
            return @"Giugno";
            break;
        case 6:
            return @"Luglio";
            break;
        case 7:
            return @"Agosto";
            break;
        case 8:
            return @"Settembre";
            break;
        case 9:
            return @"Ottobre";
            break;
        case 10:
            return @"Novembre";
            break;
        case 11:
            return @"Dicembre";
            break;
        default:
            break;
    }
    return @"";
}

@end
