//
//  CalloutAnnotation.h
//  Ecobici
//
//  Created by Christian Roman on 27/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface CalloutAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *stationId;
@property (nonatomic, strong) NSNumber *bikes;
@property (nonatomic, strong) NSNumber *free;
@property (nonatomic, assign) NSUInteger index;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
