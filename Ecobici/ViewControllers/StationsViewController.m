//
//  StationsViewController.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "StationsViewController.h"
#import "Station.h"
#import "StationAnnotation.h"
#import "CRClient+Stations.h"
#import "MRProgress.h"
#import "UIColor+Utilities.h"
#import "StationAnnotationView.h"
#import "MKMapView+ZoomLevel.h"
#import "CalloutView.h"

#define CGRectPinLevelCity          CGRectMake(0, 0, 50, 50)
#define CGRectPinLevelBorough       CGRectMake(0, 0, 25, 25)
#define CGRectPinLevelHood          CGRectMake(0, 0, 60, 60)

#define CGRectPinLevelStreet        CGRectMake(0, 0, 80, 80)
#define CGRectPinLevelBike          CGRectMake(0, 0, 100, 100)

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

@interface StationsViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

typedef NS_ENUM(NSInteger, CRDisplayMode) {
    CRDisplayModeBikes = 0,
    CRDisplayModeFree = 1
};

typedef NS_ENUM(NSInteger, CRMapZoomLevel) {
    CRMapZoomLevelCity = 0,
    CRMapZoomLevelBorough = 1,
    CRMapZoomLevelHood = 2
};

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentUserLocation;

@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) NSMutableArray *filteredMapAnnotations;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CalloutView *calloutView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *itemsRequiredItem;
@property (nonatomic, weak) IBOutlet UIStepper *itemsRequiredStepper;
@property (nonatomic, strong) NSNumber *itemsRequired;

@property (nonatomic, assign) CRDisplayMode displayMode;

@property (nonatomic, assign) CRMapZoomLevel currentMapZoomLevel;

@property (nonatomic, assign) BOOL allowsAnimation;

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, weak) IBOutlet UIToolbar *toolbarTop;

@property (nonatomic, strong) NSMutableArray *routesOverlays;

@property (nonatomic, assign) BOOL routesShown;
@property (nonatomic, assign) BOOL stationsShown;

@property (nonatomic, weak) IBOutlet UISlider *slider;

@end

@implementation StationsViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _currentUserLocation = [[CLLocation alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    // Configure map zoom level
    _currentMapZoomLevel = CRMapZoomLevelCity;
    
    // Set the display mode
    _displayMode = CRDisplayModeBikes;
    
    // Set the bikes required
    _itemsRequired = @1;
    
    _allowsAnimation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //self.navigationController.navigationBar.topItem.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshStations)];
    
    [self.navigationItem setRightBarButtonItem:refreshButtonItem animated:NO];
    
    // Region coordinates
    double lat = 19.433246;
    double lng = -99.170175;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lng), 9000, 9000);
    
    //[_mapView regionThatFits:region];
    
    [_mapView setRegion:region animated:NO];
    
    // Overlay darker-polygon
    MKMapRect worldRect = MKMapRectWorld;
    MKMapPoint point1 = MKMapRectWorld.origin;
    MKMapPoint point2 = MKMapPointMake(point1.x + worldRect.size.width, point1.y);
    MKMapPoint point3 = MKMapPointMake(point2.x, point2.y + worldRect.size.height);
    MKMapPoint point4 = MKMapPointMake(point1.x, point3.y);
    MKMapPoint points[4] = {point1, point2, point3, point4};
    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:4];
    [_mapView addOverlay:polygon];
    
    _mapAnnotations = [[NSMutableArray alloc] initWithCapacity:[_stations count]];
    
    _filteredMapAnnotations = [[NSMutableArray alloc] init];
    
    for (Station *station in _stations) {
        StationAnnotation *annotation = [[StationAnnotation alloc] init];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([station.lat doubleValue], [station.lng doubleValue]);
        [annotation setCoordinate:coordinate];
        [annotation setTitle:station.name];
        [annotation setSubtitle:station.principal];
        [annotation setStationId:station.sid];
        [annotation setBikes:station.bikes];
        [annotation setFree:station.free];
        [annotation setIdx:[_stations indexOfObject:station]];
        [_mapAnnotations addObject:annotation];
        
        if ([station.bikes intValue] > 10) {
            [_filteredMapAnnotations addObject:annotation];
        }
    }
    
    [_mapView addAnnotations:_mapAnnotations];
    _stationsShown = YES;
    
    if(![_stations count]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"Sin resultados", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)modeSelectionControlChanged:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case CRDisplayModeBikes:
            _displayMode = CRDisplayModeBikes;
            break;
        case CRDisplayModeFree:
            _displayMode = CRDisplayModeFree;
        default:
            break;
    }
    
    _allowsAnimation = NO;
    [self updateMapViewAnnotations];
}

- (IBAction)itemsRequiredStepperChanged:(id)sender
{
    [_itemsRequiredItem setTitle:[NSString stringWithFormat:@"%d", (NSInteger)_itemsRequiredStepper.value]];
    _itemsRequired = @((NSInteger)_itemsRequiredStepper.value);
    
    _allowsAnimation = NO;
    [self updateMapViewAnnotations];
}

- (int)pinColorWithValue:(NSNumber *)value bikesRequired:(NSNumber *)bikesRequired
{
    int availables = [value intValue];
    int required = [bikesRequired doubleValue];
    
    if (availables - required < 0) {
        return 4;
    } else if (availables - required < 5) {
        return 3;
    } else if (availables - required < 10) {
        return 2;
    } else {
        return 1;
    }
}

- (void)refreshStations
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    [[CRClient sharedClient] getStationsWithCompletion:^(NSArray *stations, NSError *error) {
        if (!error){
            
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            
            _stations = [[NSArray alloc] initWithArray:stations];
            
            [_mapView removeAnnotations:_mapAnnotations];
            
            _mapAnnotations = [[NSMutableArray alloc] initWithCapacity:[_stations count]];
            
            for (Station *station in _stations) {
                StationAnnotation *annotation = [[StationAnnotation alloc] init];
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([station.lat doubleValue], [station.lng doubleValue]);
                [annotation setCoordinate:coordinate];
                [annotation setTitle:station.name];
                [annotation setSubtitle:station.principal];
                [annotation setStationId:station.sid];
                [annotation setBikes:station.bikes];
                [annotation setFree:station.free];
                [annotation setIdx:[_stations indexOfObject:station]];
                [_mapAnnotations addObject:annotation];
            }
            
            [_mapView addAnnotations:_mapAnnotations];
            
            if(![_stations count]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"Sin resultados", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
            
        } else {
            
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }];
}

- (void)loadRoutes
{
    _routesOverlays = [[NSMutableArray alloc] init];
    
    /* */
    MKMapPoint *pointsArray = malloc(sizeof(CLLocationCoordinate2D) * 7);
    
    pointsArray[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.427654, -99.202999));
    pointsArray[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.427089, -99.201067));
    pointsArray[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.423131, -99.175225));
    pointsArray[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.435443, -99.149315));
    pointsArray[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.440656, -99.143054));
    pointsArray[5]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.440656, -99.143054));
    pointsArray[6]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.448067, -99.134662));
    
    MKPolyline *line = [MKPolyline polylineWithPoints:pointsArray count:7];
    
    [_routesOverlays addObject:line];
    
    free(pointsArray);
    
    /* */
    MKMapPoint *pointsArray2 = malloc(sizeof(CLLocationCoordinate2D) * 7);
    
    pointsArray2[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.419945, -99.177150));
    pointsArray2[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.423400, -99.163620));
    pointsArray2[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.425655, -99.153454));
    pointsArray2[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.427206, -99.148072));
    pointsArray2[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.425585, -99.131254));
    pointsArray2[5]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.426008, -99.129908));
    pointsArray2[6]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.425303, -99.125722));
    
    MKPolyline *line2 = [MKPolyline polylineWithPoints:pointsArray2 count:7];
    
    [_routesOverlays addObject:line2];
    
    free(pointsArray2);
    
    /* */
    
    MKMapPoint *pointsArray3 = malloc(sizeof(CLLocationCoordinate2D) * 11);
    
    pointsArray3[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.410689, -99.193889));
    pointsArray3[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.406034, -99.202687));
    pointsArray3[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.412146, -99.203159));
    pointsArray3[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.415546, -99.203888));
    pointsArray3[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.417489, -99.204961));
    pointsArray3[5]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.418703, -99.203846));
    pointsArray3[6]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.420403, -99.199983));
    pointsArray3[7]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.420686, -99.199382));
    pointsArray3[8]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.419553, -99.196464));
    pointsArray3[9]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.414615, -99.193632));
    pointsArray3[10]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.410811, -99.193889));
    
    MKPolyline *line3 = [MKPolyline polylineWithPoints:pointsArray3 count:11];
    
    [_routesOverlays addObject:line3];
    
    free(pointsArray3);
    
    /* */
    
    MKMapPoint *pointsArray4 = malloc(sizeof(CLLocationCoordinate2D) * 6);
    
    pointsArray4[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.439637, -99.183819));
    pointsArray4[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.437937, -99.177897));
    pointsArray4[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.433890, -99.171202));
    pointsArray4[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.417458, -99.163992));
    pointsArray4[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.406125, -99.160902));
    pointsArray4[5]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.405478, -99.177897));
    
    MKPolyline *line4 = [MKPolyline polylineWithPoints:pointsArray4 count:6];
    
    [_routesOverlays addObject:line4];
    
    free(pointsArray4);
    
    /* */
    
    MKMapPoint *pointsArray5 = malloc(sizeof(CLLocationCoordinate2D) * 9);
    
    pointsArray5[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.456480, -99.148616));
    pointsArray5[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.453954, -99.151830));
    pointsArray5[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.445873, -99.152767));
    pointsArray5[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.444737, -99.147277));
    pointsArray5[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.437287, -99.148884));
    pointsArray5[5]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.425795, -99.153437));
    pointsArray5[6]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.406346, -99.154910));
    pointsArray5[7]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.406725, -99.144465));
    pointsArray5[8]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.408746, -99.127325));
    
    MKPolyline *line5 = [MKPolyline polylineWithPoints:pointsArray5 count:9];
    
    [_routesOverlays addObject:line5];
    
    free(pointsArray5);
    
    /* */
    
    MKMapPoint *pointsArray6 = malloc(sizeof(CLLocationCoordinate2D) * 5);
    
    pointsArray6[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.431604, -99.177406));
    pointsArray6[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.430847, -99.180888));
    pointsArray6[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.431352, -99.196689));
    pointsArray6[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.432488, -99.208473));
    pointsArray6[4]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(19.439686, -99.205125));
    
    MKPolyline *line6 = [MKPolyline polylineWithPoints:pointsArray6 count:5];
    
    [_routesOverlays addObject:line6];
    
    free(pointsArray6);
    
    [_mapView addOverlays:_routesOverlays];
    
    _routesShown = YES;
    
    /*
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ciclovias" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                           error:&error];
    
    NSArray *features = [data objectForKey:@"features"];
    
    for (NSDictionary *feature in features) {
        NSDictionary *geometry = [feature objectForKey:@"geometry"];
        NSArray *coordinates = [geometry objectForKey:@"coordinates"];
        
        CLLocationCoordinate2D *coordinateArray
        = malloc(sizeof(CLLocationCoordinate2D) * coordinates.count);
        
        int caIndex = 0;
        for (NSArray *coordinate in coordinates) {
            coordinateArray[caIndex] = CLLocationCoordinate2DMake([[coordinate objectAtIndex:0] doubleValue], [[coordinate objectAtIndex:1] doubleValue]);
            caIndex++;
        }
        
    }
    */
    
}

- (IBAction)showRemoveRoutes:(id)sender
{
    if (_routesShown) {
        [_mapView removeOverlays:_routesOverlays];
        _routesShown = NO;
    } else {
        if (!_routesOverlays) {
            [self loadRoutes];
        } else {
            [_mapView addOverlays:_routesOverlays];
        }
        _routesShown = YES;
    }
}

- (IBAction)showRemoveStations:(id)sender
{
    if (_stationsShown) {
        [_mapView removeAnnotations:_mapAnnotations];
        _stationsShown = NO;
        
        CGRect toolbarFrame = _toolbar.frame;
        toolbarFrame.origin.y = self.view.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            _toolbar.frame = toolbarFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
        
    } else {
        [_mapView addAnnotations:_mapAnnotations];
        _stationsShown = YES;
        
        CGRect toolbarFrame = _toolbar.frame;
        toolbarFrame.origin.y = self.view.frame.size.height - _toolbar.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            _toolbar.frame = toolbarFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
    }
}

- (IBAction)sliderChanged:(id)sender
{
    int sliderValue = (int)_slider.value;
    if (sliderValue == 1) {
        [_mapView removeAnnotations:_mapAnnotations];
        [_mapView addAnnotations:_filteredMapAnnotations];
    } else {
        [_mapView removeAnnotations:_filteredMapAnnotations];
        [_mapView addAnnotations:_mapAnnotations];
    }
}

#pragma mark - Helpers

- (void)updateMapViewAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:_mapAnnotations];
}

- (CGRect)rectFromMapLevel
{
    CGRect rect = CGRectZero;
    switch (_currentMapZoomLevel) {
        case CRMapZoomLevelCity:
            rect = CGRectPinLevelCity;
            break;
        case CRMapZoomLevelBorough:
            rect = CGRectPinLevelBorough;
            break;
        case CRMapZoomLevelHood:
            rect = CGRectPinLevelHood;
            break;
        default:
            break;
    }
    return rect;
}

- (CGRect)calloutViewRectFromMapLevel
{
    CGRect rect = CGRectZero;
    switch (_currentMapZoomLevel) {
        case CRMapZoomLevelBorough:
            rect = CGRectMake(-80, -70, 185, 85);
            break;
        case CRMapZoomLevelHood:
            rect = CGRectMake(-63, -60, 185, 85);
            break;
        default:
            break;
    }
    return rect;
}

- (NSString *)stringFromMapLevelAndPinColor:(int)pinColor;
{
    NSString *mapLevelString;
    
    switch (_currentMapZoomLevel) {
        case CRMapZoomLevelCity:
            mapLevelString = @"city";
            break;
        case CRMapZoomLevelBorough:
            mapLevelString = @"borough";
            break;
        case CRMapZoomLevelHood:
            mapLevelString = @"hood";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"pins-%@-level%d", mapLevelString, pinColor];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonRenderer.fillColor = [UIColor blackColor];
        polygonRenderer.alpha = 0.2;
        return polygonRenderer;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.strokeColor = [UIColor CR_secondColor];
        polylineRenderer.lineWidth = 2;
        return polylineRenderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    StationAnnotationView *annotationView = (StationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (!annotationView) {
        annotationView = [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        
    } else {
        annotationView.annotation = annotation;
    }
    
    StationAnnotation *stationAnnotation = (StationAnnotation *)annotation;
    
    NSNumber *bikesOrFree = stationAnnotation.bikes;
    if (_displayMode == CRDisplayModeFree) {
        bikesOrFree = stationAnnotation.free;
    }
    
    int pinColor = [self pinColorWithValue:bikesOrFree bikesRequired:_itemsRequired];
    
    UIImage *image = [UIImage imageNamed:[self stringFromMapLevelAndPinColor:pinColor]];
    annotationView.image = image;
    annotationView.frame = [self rectFromMapLevel];
    annotationView.contentMode = UIViewContentModeScaleAspectFill;
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (_currentMapZoomLevel != CRMapZoomLevelCity) {
        
        // Center the mapView
        StationAnnotation *stationAnnotation = view.annotation;
        
        [_mapView setCenterCoordinate:stationAnnotation.coordinate animated:YES];
        
        _calloutView = [[CalloutView alloc] initWithFrame:[self calloutViewRectFromMapLevel]
                                                    bikes:stationAnnotation.bikes
                                                     free:stationAnnotation.free
                                                     name:stationAnnotation.title];
        
        [view addSubview:_calloutView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_currentMapZoomLevel != CRMapZoomLevelCity) {
        [_calloutView removeFromSuperview];
        _calloutView = nil;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_stationsShown) {
        int zoomLevel = [_mapView zoomLevel];
        
        if (zoomLevel >= 12 && zoomLevel <= 19) {
            if (zoomLevel == 12) {
                
                if (_currentMapZoomLevel != CRMapZoomLevelCity) {
                    _currentMapZoomLevel = CRMapZoomLevelCity;
                    
                    _allowsAnimation = YES;
                    [self updateMapViewAnnotations];
                }
                
            } else if (zoomLevel >= 13 && zoomLevel <= 15) {
                
                if (_currentMapZoomLevel != CRMapZoomLevelBorough) {
                    _currentMapZoomLevel = CRMapZoomLevelBorough;
                    
                    _allowsAnimation = YES;
                    [self updateMapViewAnnotations];
                }
                
            } else if (zoomLevel >= 16 && zoomLevel <= 19) {
                
                if (_currentMapZoomLevel != CRMapZoomLevelHood) {
                    _currentMapZoomLevel = CRMapZoomLevelHood;
                    
                    _allowsAnimation = YES;
                    [self updateMapViewAnnotations];
                }
                
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if (_allowsAnimation) {
        _allowsAnimation = NO;
        for (MKAnnotationView *aV in views) {
            if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
                continue;
            }
            MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
            if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) {
                continue;
            }
            aV.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.2 delay:0.01 * [views indexOfObject:aV] options:UIViewAnimationOptionCurveLinear animations:^{
                aV.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

@end
