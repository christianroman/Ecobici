//
//  MKMapView+ZoomLevel.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (ZoomLevel)

- (NSUInteger)zoomLevel
{
    return (21 - round(log2(self.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.bounds.size.width))));
}

@end
