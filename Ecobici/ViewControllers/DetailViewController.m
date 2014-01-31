//
//  DetailViewController.m
//  Ecobici
//
//  Created by Christian Roman on 28/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "DetailViewController.h"
#import "WilcardGestureRecognizer.h"
#import "StationAnnotation.h"
#import "Station.h"
#import "UIColor+Utilities.h"
#import "UIImage+TintColor.h"
#import "CRCoreDataController.h"
#import "AppDelegate.h"
#import "EXTScope.h"

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

@interface DetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIView *dataView;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *bikesLabel;
@property (nonatomic, weak) IBOutlet UILabel *freeLabel;

@property (nonatomic, weak) UIButton *userLocationButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) WildcardGestureRecognizer *tapInterceptor;

@property (nonatomic, assign) CGRect dataFrame;
@property (nonatomic, assign) CGRect mapViewFrame;

@property (nonatomic, strong) MKRoute *currentStationRoute;
@property (nonatomic, strong) MKPolyline *routeStationOverlay;

@property (nonatomic, assign) BOOL stationInFavorites;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation DetailViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userLocation = [[CLLocation alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0f;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
}

- (BOOL)stationSavedInFavorites
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Station managedObjectEntityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"sid == %d", [_station.sid intValue]]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    if ([_managedObjectContext countForFetchRequest:fetchRequest error:&error]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(getDirections)];
    
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
    
    self.title = _station.name;
    
    [_addressLabel setText:@"Obteniendo información..."];
    [_distanceLabel setText:@"-"];
    [_bikesLabel setText:[NSString stringWithFormat:@"%@", _station.bikes ? _station.bikes : @"-"]];
    [_freeLabel setText:[NSString stringWithFormat:@"%@", _station.free ? _station.free : @"-"]];
    
    [_distanceLabel setBackgroundColor:[UIColor CR_firstColor]];
    [_distanceLabel.layer setCornerRadius:3.0f];
    
    StationAnnotation *annotation = [[StationAnnotation alloc] init];
    [annotation setTitle:_station.name];
    [annotation setSubtitle:_station.principal];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]);
    [annotation setCoordinate:coordinate];
    [self.mapView addAnnotation:annotation];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]), 500, 500);
    MKMapRect mapRect = MKMapRectForCoordinateRegion(region);
    [_mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(74, 0, 0, 0) animated:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:[_station.lat doubleValue] longitude:[_station.lng doubleValue]];
    [geocoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSString *address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_addressLabel setText:address];
        });
        
    }];
    
    _tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    __weak WildcardGestureRecognizer *tapInterceptor = _tapInterceptor;
    @weakify(self)
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        @strongify(self)
        [self.mapView removeGestureRecognizer:tapInterceptor];
        self.tapInterceptor = nil;
        [self openMapView];
    };
    [self.mapView addGestureRecognizer:tapInterceptor];
}

#pragma mark - Class methods

- (void)calculateDirectionsToStation
{
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    [directionsRequest setSource:source];
    CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoords addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [directionsRequest setDestination:destination];
    [directionsRequest setTransportType:MKDirectionsTransportTypeAny];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            return;
        }
        
        _currentStationRoute = [response.routes firstObject];
        if(_routeStationOverlay) {
            [_mapView removeOverlay:_routeStationOverlay];
        }
        
        _routeStationOverlay = _currentStationRoute.polyline;
        
        [_mapView addOverlay:_routeStationOverlay];
    }];
}

- (void)updateDistanceToStation
{
    CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:[_station.lat doubleValue] longitude:[_station.lng doubleValue]];
    CLLocationDistance meters = [_userLocation distanceFromLocation:stationLocation];
    
    NSString *formattedString;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    formattedString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:meters / 1000]]];
    [_distanceLabel setText:formattedString];
}

- (void)openMapView
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.dataFrame = self.dataView.frame;
                         self.dataView.frame = CGRectMake(self.dataView.frame.origin.x, self.view.frame.size.height, self.dataView.frame.size.width, self.dataView.frame.size.height);
                         
                         self.mapViewFrame = self.mapView.frame;
                         
                         CGRect selfViewFrame = self.view.frame;
                         selfViewFrame.origin.y = 0;
                         self.mapView.frame = selfViewFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         self.userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                         [self.userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];
                         [self.userLocationButton setFrame:CGRectMake(self.mapView.frame.origin.x + 10, self.mapView.frame.origin.y + 10, 32, 32)];
                         [self.userLocationButton setBackgroundImage:[UIImage imageNamed:@"userLocation"] forState:UIControlStateNormal];
                         [self.userLocationButton setAlpha:0.0];
                         [self.mapView addSubview:self.userLocationButton];
                         
                         UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Cerrar" style:UIBarButtonItemStyleDone target:self action:@selector(closeMapView)];
                         
                         [self.navigationItem setLeftBarButtonItem:close animated:YES];
                         
                         self.navigationItem.title  = @"Estación";
                         self.navigationItem.titleView = nil;
                         
                         [UIView animateWithDuration:0.5f animations:^{
                             
                             [self.userLocationButton setAlpha:0.8];
                             [self zoomMapViewToFitAnnotations];
                             
                         } completion:^(BOOL finished) {
                             
                             if (finished) {
                                 [self.mapView setUserInteractionEnabled:YES];
                                 [self.mapView setZoomEnabled:YES];
                                 [self.mapView setScrollEnabled:YES];
                             }
                             
                         }];
                         
                     }];
}

- (void)closeMapView
{
    [self.mapView setUserInteractionEnabled:NO];
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    
    self.navigationItem.title = _station.name;
    
    if(_routeStationOverlay) {
        [_mapView removeOverlay:_routeStationOverlay];
        _routeStationOverlay = nil;
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.userLocationButton.alpha = 0;
                         self.dataView.frame = self.dataFrame;
                         self.mapView.frame = self.mapViewFrame;
                         self.navigationItem.titleView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished){
                         
                         if (finished) {
                             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]), 500, 500);
                             MKMapRect mapRect = MKMapRectForCoordinateRegion(region);
                             [_mapView setVisibleMapRect:mapRect animated:YES];
                             
                             [self.userLocationButton removeFromSuperview];
                             self.userLocationButton = nil;
                             
                             _tapInterceptor = [[WildcardGestureRecognizer alloc] init];
                             __weak WildcardGestureRecognizer *tapInterceptor = _tapInterceptor;
                             @weakify(self)
                             tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
                                 @strongify(self)
                                 [self.mapView removeGestureRecognizer:tapInterceptor];
                                 self.tapInterceptor = nil;
                                 [self openMapView];
                             };
                             [self.mapView addGestureRecognizer:tapInterceptor];
                         }
                     }];
}

- (void)zoomMapViewToFitAnnotations
{
    CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:[_station.lat doubleValue] longitude:[_station.lng doubleValue]];
    CLLocationDistance meters = [self.userLocation distanceFromLocation:storeLocation];
    
    MKCoordinateRegion region;
    
    if (meters < 12000) {
        NSArray *annotations = self.mapView.annotations;
        NSInteger count = [self.mapView.annotations count];
        
        MKMapPoint points[count];
        for(int i = 0; i < count; i++) {
            CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
            points[i] = MKMapPointForCoordinate(coordinate);
        }
        
        MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
        region = MKCoordinateRegionForMapRect(mapRect);
        
        float minimumZoomArc = 0.01; //0.014;
        
        region.span.latitudeDelta  *= 1.15;
        region.span.longitudeDelta *= 1.15;
        
        if(region.span.latitudeDelta > 360) { region.span.latitudeDelta  = 360; }
        if(region.span.longitudeDelta > 360) { region.span.longitudeDelta = 360; }
        
        if(region.span.latitudeDelta  < minimumZoomArc) { region.span.latitudeDelta  = minimumZoomArc; }
        if(region.span.longitudeDelta < minimumZoomArc) { region.span.longitudeDelta = minimumZoomArc; }
        
        [self calculateDirectionsToStation];
        
    } else {
        region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]), 500, 500);
    }
    
    [self.mapView setRegion:region animated:YES];
}

- (void)getDirections
{
    _stationInFavorites = [self stationSavedInFavorites];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Acciones" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@ Favoritos", _stationInFavorites ? @"Eliminar de" : @"Agregar a" ], @"Direcciones", nil];
    [actionSheet showInView:self.view];
}

- (void)centerMapUserLocation
{
    [self.mapView setCenterCoordinate:self.userLocation.coordinate animated:YES];
}

#pragma mark - Helpers

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (!annotationView) {
        
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.canShowCallout = NO;
        annotationView.draggable = NO;
        
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor CR_firstColor];
    renderer.lineWidth = 2.0;
    return renderer;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            if (_stationInFavorites) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Station managedObjectEntityName]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"sid == %d", [_station.sid intValue]]];
                
                NSError *error = nil;
                NSArray *managedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                for (NSManagedObject *managedObject in managedObjects) {
                    [_managedObjectContext deleteObject:managedObject];
                }
                [_managedObjectContext save:&error];
            } else {
                [MTLManagedObjectAdapter managedObjectFromModel:_station
                                           insertingIntoContext:_managedObjectContext
                                                          error:NULL];
                
                NSError *error = nil;
                if ([_managedObjectContext save:&error]) {
                    _stationInFavorites = YES;
                } else {
                    _stationInFavorites = NO;
                }
            }
            break;
        }
        case 1: {
            CLLocationCoordinate2D storeCoordinate = CLLocationCoordinate2DMake([_station.lat doubleValue], [_station.lng doubleValue]);
            MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:storeCoordinate addressDictionary:nil];
            MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
            destination.name = _station.name;
            NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
            NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     MKLaunchOptionsDirectionsModeDriving,
                                     MKLaunchOptionsDirectionsModeWalking,
                                     MKLaunchOptionsDirectionsModeKey, nil];
            [MKMapItem openMapsWithItems: items launchOptions: options];
            break;
        }
        case 2:
            break;
        default:
            break;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _userLocation = [locations lastObject];
    [self updateDistanceToStation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
