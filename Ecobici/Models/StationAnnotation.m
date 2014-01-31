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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, sid: %@ bikes: %@, free: %@>", NSStringFromClass([self class]), self, self.stationId, self.bikes, self.free];
}

@end
