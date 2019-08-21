//
//  PathViewCell.m
//  SportTracker
//
//  Created by Domenico Barretta on 13/05/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "PathViewCell.h"

@implementation PathViewCell

@synthesize dateLabel, distanceLabel, durationLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
