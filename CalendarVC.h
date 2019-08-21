//
//  CalendarVC.h
//  SportTracker
//
//  Created by Domenico Barretta on 09/07/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import <UIKit/UIKit.h>

NSArray *createdAt;
NSArray *parseSpot3;
NSArray *hadSession;

@interface CalendarVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *nextMonth;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;

- (IBAction)nextAction:(id)sender;
- (IBAction)prevAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *Month;

@property (nonatomic, strong) NSArray *queryResult;
@property (nonatomic, weak) NSDate *selectedDate;

@end
