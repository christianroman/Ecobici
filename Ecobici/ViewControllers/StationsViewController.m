//
//  StationsViewController.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "MapSettingsViewController.h"
#import "StationsViewController.h"
#import "StationAnnotationView.h"
#import "DetailViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "CalloutAnnotation.h"
#import "CRClient+Stations.h"
#import "StationAnnotation.h"
#import "UIColor+Utilities.h"
#import "MRProgress.h"
#import "Station.h"

#define CGRectPinLevelCity                      CGRectMake(0, 0, 50, 50)
#define CGRectPinLevelBorough                   CGRectMake(0, 0, 25, 25)
#define CGRectPinLevelHood                      CGRectMake(0, 0, 60, 60)
#define CGRectPinLevelStreet                    CGRectMake(0, 0, 80, 80)
#define CGRectPinLevelBike                      CGRectMake(0, 0, 100, 100)

#define kDidSwitchShowHideStationsNotification  @"kDidSwitchShowHideStationsNotification"
#define kDidSwitchShowHideRoutesNotification    @"kDidSwitchShowHideRoutesNotification"

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

@property (nonatomic, assign) BOOL filtered;
@property (nonatomic, assign) BOOL routesShown;
@property (nonatomic, assign) BOOL stationsShown;
@property (nonatomic, assign) BOOL allowsAnimation;
@property (nonatomic, strong) NSArray *filterValues;
@property (nonatomic, strong) NSNumber *itemsRequired;
@property (nonatomic, assign) CRDisplayMode displayMode;
@property (nonatomic, strong) NSMutableArray *routesOverlays;
@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) NSArray *filteredMapAnnotations;
@property (nonatomic, strong) CLLocation *currentUserLocation;
@property (nonatomic, assign) CRMapZoomLevel currentMapZoomLevel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbarTop;
@property (nonatomic, weak) IBOutlet UISlider *filterSlider;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbarBottom;
@property (nonatomic, weak) IBOutlet UIStepper *itemsRequiredStepper;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *itemsRequiredItem;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureDynamicDrawerViewController];
    [self configureUI];
    [self configureMapView];
    [self fetchStations];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    _currentMapZoomLevel = CRMapZoomLevelCity;
    _displayMode = CRDisplayModeBikes;
    _itemsRequired = @1;
    _allowsAnimation = YES;
    _filtered = NO;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:kDidSwitchShowHideStationsNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [self showRemoveStations:notification];
     }];
    
    [center addObserverForName:kDidSwitchShowHideRoutesNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
     {
         [self showRemoveRoutes:notification];
     }];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"routesShown"];
}

- (void)configureUI
{
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    UIBarButtonItem *paneRevealRightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Right Reveal Icon"]
                                                                                     style:UIBarButtonItemStyleBordered
                                                                                    target:self
                                                                                    action:@selector(dynamicsDrawerRevealRightBarButtonItemTapped:)];
    
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                       target:self
                                                                                       action:@selector(refreshStations)];
    
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                      target:self
                                                                                      action:@selector(showHideActionToolbar)];
    
    [self.navigationItem setRightBarButtonItems:@[paneRevealRightBarButtonItem, filterButtonItem, refreshButtonItem]];
    
    [_toolbarTop setBackgroundImage:[UIImage imageNamed:@"Slider Background"]
                 forToolbarPosition:UIBarPositionAny
                         barMetrics:UIBarMetricsDefault];
}

- (void)configureDynamicDrawerViewController
{
    _dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    MapSettingsViewController *mapSettingsViewController = [MapSettingsViewController new];
    [_dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerParallaxStyler styler],
                                                         [MSDynamicsDrawerShadowStyler styler]]
                                          forDirection:MSDynamicsDrawerDirectionRight];
    [_dynamicsDrawerViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionRight];
    [_dynamicsDrawerViewController setDrawerViewController:mapSettingsViewController forDirection:MSDynamicsDrawerDirectionRight];
}

- (void)fetchStations
{
    if (!_stations) {
        [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        [[CRClient sharedClient] getStationsWithCompletion:^(NSArray *stations, NSError *error) {
            if (!error){
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                _stations = stations;
                [self configureMapViewForAnnotations];
            } else {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                    message:[error localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

- (void)configureMapView
{
    double lat = 19.433246;
    double lng = -99.170175;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lng), 9000, 9000);
    
    [_mapView setRegion:region animated:NO];
    
    MKMapRect worldRect = MKMapRectWorld;
    MKMapPoint point1 = MKMapRectWorld.origin;
    MKMapPoint point2 = MKMapPointMake(point1.x + worldRect.size.width, point1.y);
    MKMapPoint point3 = MKMapPointMake(point2.x, point2.y + worldRect.size.height);
    MKMapPoint point4 = MKMapPointMake(point1.x, point3.y);
    MKMapPoint points[4] = {point1, point2, point3, point4};
    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:4];
    [_mapView addOverlay:polygon];
}

- (void)configureMapViewForAnnotations
{
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
    _stationsShown = YES;
    [[NSUserDefaults standardUserDefaults] setBool:_stationsShown forKey:@"stationsShown"];
}

- (void)dynamicsDrawerRevealRightBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen
                                        inDirection:MSDynamicsDrawerDirectionRight
                                           animated:YES
                              allowUserInterruption:YES
                                         completion:nil];
}

- (void)updateMapViewAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:_mapAnnotations];
}

- (void)updateFilteredMapViewAnnotationsAndFetchingRequired:(BOOL)required
{
    if (required) {
        _filteredMapAnnotations = nil;
        _filteredMapAnnotations = [NSArray new];
        _filteredMapAnnotations = [_mapAnnotations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [self evaluateMapAnnotation:object];
        }]];
    }
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotations:_filteredMapAnnotations];
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
    
    if (_filtered) {
        [self updateFilteredMapViewAnnotationsAndFetchingRequired:YES];
    } else {
        [self updateMapViewAnnotations];
    }
}

- (IBAction)itemsRequiredStepperChanged:(id)sender
{
    [_itemsRequiredItem setTitle:[NSString stringWithFormat:@"%d", (NSInteger)_itemsRequiredStepper.value]];
    _itemsRequired = @((NSInteger)_itemsRequiredStepper.value);
    _allowsAnimation = NO;
    
    if (_filtered) {
        [self updateFilteredMapViewAnnotationsAndFetchingRequired:YES];
    } else {
        [self updateMapViewAnnotations];
    }
}

- (IBAction)sliderChanged:(id)sender
{
    int sliderValue = (NSUInteger)(_filterSlider.value + 0.5);
    [_filterSlider setValue:sliderValue animated:NO];
    _filtered = sliderValue == 4 ? NO : YES;
    [self updateFilteredMapViewAnnotationsAndFetchingRequired:YES];
}

- (BOOL)evaluateMapAnnotation:(StationAnnotation *)stationAnnotation
{
    NSNumber *bikesOrFree = stationAnnotation.bikes;
    if (_displayMode == CRDisplayModeFree) {
        bikesOrFree = stationAnnotation.free;
    }
    return [self pinColorWithValue:bikesOrFree bikesRequired:_itemsRequired] <= (int)_filterSlider.value;
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
            
            _filtered = NO;
            [_filterSlider setValue:4];
            
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Sin resultados"
                                                                   delegate:nil cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        } else {
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error localizedDescription]
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)loadRoutes
{
    _routesOverlays = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ciclovias" ofType:@"json"];
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    
    NSArray *features = [JSONObject objectForKey:@"features"];
    
    for (NSDictionary *feature in features) {
        NSArray *coordinates = [feature objectForKey:@"coordinates"];
        CLLocationCoordinate2D *coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * coordinates.count);
        int arrayIndex = 0;
        for (NSArray *coordinate in coordinates) {
            coordinateArray[arrayIndex] = CLLocationCoordinate2DMake([[coordinate objectAtIndex:1] doubleValue], [[coordinate objectAtIndex:0] doubleValue]);
            arrayIndex++;
        }
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinateArray count:coordinates.count];
        free(coordinateArray);
        [_routesOverlays addObject:polyline];
    }
    
    [_mapView addOverlays:_routesOverlays];
    _routesShown = YES;
}

- (void)showHideActionToolbar
{
    if ([_toolbarTop isHidden]) {
        [_toolbarTop setHidden:NO];
        [UIView animateWithDuration:0.4 animations:^{
            [_toolbarTop setAlpha:1.0];
            _toolbarTop.frame = ^{
                CGRect frame = _toolbarTop.frame;
                frame.origin.y += _toolbarTop.frame.size.height;
                return frame;
            }();
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            [_toolbarTop setAlpha:0];
            _toolbarTop.frame = ^{
                CGRect frame = _toolbarTop.frame;
                frame.origin.y -= _toolbarTop.frame.size.height;
                return frame;
            }();
        } completion:^(BOOL finished) {
            if (finished) {
                [_toolbarTop setHidden:YES];
            }
        }];
    }
}

- (void)showRemoveStations:(NSNotification *)notification
{
    if (_stationsShown) {
        [_mapView removeAnnotations:_mapView.annotations];
        _stationsShown = NO;
        BOOL filterToolbarIsHidden = [_toolbarTop isHidden];
        [UIView animateWithDuration:0.3 animations:^{
            _toolbarBottom.frame = ^{
                CGRect toolbarFrame = _toolbarBottom.frame;
                toolbarFrame.origin.y = self.view.frame.size.height;
                return toolbarFrame;
            }();
            if (!filterToolbarIsHidden) {
                [_toolbarTop setAlpha:0];
                _toolbarTop.frame = ^{
                    CGRect frame = _toolbarTop.frame;
                    frame.origin.y -= _toolbarTop.frame.size.height;
                    return frame;
                }();
            }
        } completion:^(BOOL finished) {
            if (finished) {
                if (!filterToolbarIsHidden) {
                    [_toolbarTop setHidden:YES];
                }
            }
        }];
        
    } else {
        if (!_filtered) {
            [_mapView addAnnotations:_mapAnnotations];
        } else {
            [_mapView addAnnotations:_filteredMapAnnotations];
        }
        _stationsShown = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            _toolbarBottom.frame = ^{
                CGRect toolbarFrame = _toolbarBottom.frame;
                toolbarFrame.origin.y = self.view.frame.size.height - _toolbarBottom.frame.size.height;
                return toolbarFrame;
            }();
        } completion:nil];
    }
    [[NSUserDefaults standardUserDefaults] setBool:_stationsShown forKey:@"stationsShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showRemoveRoutes:(NSNotification *)notification
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
    [[NSUserDefaults standardUserDefaults] setBool:_routesShown forKey:@"routesShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showStationDetail:(UIButton *)sender
{
    Station *station = [_stations objectAtIndex:sender.tag];
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    [detailViewController setStation:station];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Helpers

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
            mapLevelString = @"City";
            break;
        case CRMapZoomLevelBorough:
            mapLevelString = @"Borough";
            break;
        case CRMapZoomLevelHood:
            mapLevelString = @"Hood";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"Pin %@ %d", mapLevelString, pinColor];
}

- (CGPoint)pointFromCalloutAnnotation
{
    CGPoint point = CGPointZero;
    switch (_currentMapZoomLevel) {
        case CRMapZoomLevelBorough:
            point = CGPointMake(0, -50);
            break;
        case CRMapZoomLevelHood:
            point = CGPointMake(0, -60);
            break;
        default:
            break;
    }
    return point;
}

- (float)delayFromMapZoomLevel
{
    float delay = 0;
    if (_currentMapZoomLevel == CRMapZoomLevelCity) {
        delay = 0.008;
    } else {
        delay = 0.004;
    }
    return delay;
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
    if ([annotation isKindOfClass:[CalloutAnnotation class]]) {
        
        CalloutAnnotation *calloutAnnotation = (CalloutAnnotation *)annotation;
        
        NSString *AnnotationViewID = @"calloutAnnotationViewID";
        
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        view.frame = CGRectMake(0, 0, 185, 85);
        view.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:view.bounds];
        [button setBackgroundImage:[UIImage imageNamed:@"Callout"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"Callout Selected"] forState:UIControlStateHighlighted];
        [button setTag:calloutAnnotation.index];
        [button addTarget:self action:@selector(showStationDetail:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        UILabel *bikesLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, 35, 25)];
        [bikesLabel setText:[NSString stringWithFormat:@"%@", calloutAnnotation.bikes ? calloutAnnotation.bikes : @"-"]];
        [bikesLabel setTextColor:[UIColor colorWithHex:0x404040]];
        [bikesLabel setFont:[UIFont boldSystemFontOfSize:26.0f]];
        [bikesLabel setMinimumScaleFactor:0.4];
        [bikesLabel sizeToFit];
        [button addSubview:bikesLabel];
        
        UILabel *freeLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 8, 35, 25)];
        [freeLabel setText:[NSString stringWithFormat:@"%@", calloutAnnotation.free ? calloutAnnotation.free : @"-"]];
        [freeLabel setTextColor:[UIColor colorWithHex:0x404040]];
        [freeLabel setFont:[UIFont boldSystemFontOfSize:26.0f]];
        [freeLabel setMinimumScaleFactor:0.4];
        [freeLabel sizeToFit];
        [button addSubview:freeLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 165, 18)];
        [nameLabel setText:[NSString stringWithFormat:@"%@", calloutAnnotation.title]];
        [nameLabel setTextColor:[UIColor CR_firstColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setAdjustsFontSizeToFitWidth:YES];
        [nameLabel setMinimumScaleFactor:0.4];
        [button addSubview:nameLabel];
        
        view.canShowCallout = NO;
        view.centerOffset = [self pointFromCalloutAnnotation];
        
        return view;
        
    } else if ([annotation isKindOfClass:[StationAnnotation class]]) {
        
        NSString *AnnotationViewID = @"stationAnnotationViewID";
        
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
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (_currentMapZoomLevel != CRMapZoomLevelCity) {
        
        StationAnnotation *stationAnnotation = view.annotation;
        
        [_mapView setCenterCoordinate:stationAnnotation.coordinate animated:YES];
        
        if ([view.annotation isKindOfClass:[StationAnnotation class]]) {
            StationAnnotation *stationAnnotation = view.annotation;
            if (!stationAnnotation.calloutAnnotation) {
                CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] initWithCoordinate:stationAnnotation.coordinate title:stationAnnotation.title];
                [calloutAnnotation setStationId:stationAnnotation.stationId];
                [calloutAnnotation setBikes:stationAnnotation.bikes];
                [calloutAnnotation setFree:stationAnnotation.free];
                [calloutAnnotation setIndex:stationAnnotation.idx];
                stationAnnotation.calloutAnnotation = calloutAnnotation;
                [_mapView addAnnotation:calloutAnnotation];
            }
        }
        
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_currentMapZoomLevel != CRMapZoomLevelCity) {
        if([view.annotation isKindOfClass:[StationAnnotation class]]) {
            StationAnnotation *stationAnnotation = view.annotation;
            if (stationAnnotation.calloutAnnotation) {
                [mapView removeAnnotation:stationAnnotation.calloutAnnotation];
                stationAnnotation.calloutAnnotation = nil;
            }
        }
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
                    if (_filtered) {
                        [self updateFilteredMapViewAnnotationsAndFetchingRequired:NO];
                    } else {
                        [self updateMapViewAnnotations];
                    }
                }
            } else if (zoomLevel >= 13 && zoomLevel <= 15) {
                if (_currentMapZoomLevel != CRMapZoomLevelBorough) {
                    _currentMapZoomLevel = CRMapZoomLevelBorough;
                    _allowsAnimation = YES;
                    if (_filtered) {
                        [self updateFilteredMapViewAnnotationsAndFetchingRequired:NO];
                    } else {
                        [self updateMapViewAnnotations];
                    }
                }
            } else if (zoomLevel >= 16 && zoomLevel <= 19) {
                if (_currentMapZoomLevel != CRMapZoomLevelHood) {
                    _currentMapZoomLevel = CRMapZoomLevelHood;
                    _allowsAnimation = YES;
                    if (_filtered) {
                        [self updateFilteredMapViewAnnotationsAndFetchingRequired:NO];
                    } else {
                        [self updateMapViewAnnotations];
                    }
                }
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if (_allowsAnimation) {
        _allowsAnimation = NO;
        for (MKAnnotationView *annotationView in views) {
            if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
                continue;
            }
            MKMapPoint point =  MKMapPointForCoordinate(annotationView.annotation.coordinate);
            if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) {
                continue;
            }
            annotationView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.1 delay:[self delayFromMapZoomLevel] * [views indexOfObject:annotationView] options:UIViewAnimationOptionCurveLinear animations:^{
                annotationView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
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
