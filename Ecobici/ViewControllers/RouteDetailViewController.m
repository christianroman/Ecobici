//
//  RouteDetailViewController.m
//  Ecobici
//
//  Created by Christian Roman on 31/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "UIColor+Utilities.h"
#import "Route.h"

@import MapKit;
@import CoreLocation;

@interface RouteDetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocation *currentUserLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPolyline *polyline;

@end

@implementation RouteDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createPolylineFromArray];
    [_mapView addOverlay:_polyline];
    [_mapView setVisibleMapRect:_polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:NO];
    
    self.title = _route.name;
}

- (void)createPolylineFromArray
{
    CLLocationCoordinate2D *coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * _route.coordinates.count);
    int arrayIndex = 0;
    for (NSArray *coordinate in _route.coordinates) {
        coordinateArray[arrayIndex] = CLLocationCoordinate2DMake([[coordinate objectAtIndex:1] doubleValue], [[coordinate objectAtIndex:0] doubleValue]);
        arrayIndex++;
    }
    _polyline = [MKPolyline polylineWithCoordinates:coordinateArray count:_route.coordinates.count];
    free(coordinateArray);
}

#pragma mark - Class Methods

- (void)setUp
{
    _currentUserLocation = [[CLLocation alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 10.0f;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.strokeColor = [UIColor CR_thirdColor];
        polylineRenderer.lineWidth = 2;
        return polylineRenderer;
    }
    return nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _currentUserLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
