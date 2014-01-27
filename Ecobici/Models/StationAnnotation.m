//
//  StationAnnotation.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "StationAnnotation.h"

@implementation StationAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
    }
    return self;
}

@end
