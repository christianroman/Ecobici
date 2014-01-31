//
//  StationAnnotation.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>

@class CalloutAnnotation;

@interface StationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSNumber *stationId;
@property (nonatomic, strong) NSNumber *bikes;
@property (nonatomic, strong) NSNumber *free;
@property (nonatomic, assign) NSInteger idx;

@property (nonatomic, weak) CalloutAnnotation *calloutAnnotation;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
