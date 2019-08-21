//
//  PathViewCell.h
//  SportTracker
//
//  Created by Domenico Barretta on 13/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.

//
#import <UIKit/UIKit.h>

@interface PathViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end
