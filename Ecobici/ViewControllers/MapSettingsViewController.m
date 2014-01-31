//
//  MapSettingsViewController.m
//  Ecobici
//
//  Created by Christian Roman on 28/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "MapSettingsViewController.h"

#define kDidSwitchShowHideStationsNotification  @"kDidSwitchShowHideStationsNotification"
#define kDidSwitchShowHideRoutesNotification    @"kDidSwitchShowHideRoutesNotification"

@interface MapSettingsViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *stationsSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *routesSwitch;

@end

@implementation MapSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_stationsSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"stationsShown"]];
    [_routesSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"routesShown"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class methods

- (IBAction)showHideStations:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSwitchShowHideStationsNotification object:nil];
}

- (IBAction)showHideRoutes:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSwitchShowHideRoutesNotification object:nil];
}

@end
