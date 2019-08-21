//
//  MapPoint.m
//  SportTracker
//
//  Created by Domenico Barretta on 13/08/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint
@synthesize coordinate,title,subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    return self;
}


@end
