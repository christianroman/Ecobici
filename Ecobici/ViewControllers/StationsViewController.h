//
//  StationsViewController.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@interface StationsViewController : UIViewController

@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) CLLocation *location;

@end
