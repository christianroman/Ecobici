//
//  MainViewController.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "MainViewController.h"
#import "CRClient+Stations.h"
#import "Station.h"
#import "MRProgressOverlayView.h"
#import "StationsViewController.h"
#import "UIColor+Utilities.h"
#import "MSDynamicsDrawerViewController.h"

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)pushStationsViewController:(id)sender
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    [[CRClient sharedClient] getStationsWithCompletion:^(NSArray *stations, NSError *error) {
        if (!error){
            
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            
            StationsViewController *stationsViewController = [[StationsViewController alloc] init];
            [stationsViewController setStations:stations];
            [self.navigationController pushViewController:stationsViewController animated:YES];
            
        } else {
            
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.imageView.image = [UIImage imageNamed:@"Background"];
    
    [_button setTitleColor:self.navigationController.view.window.tintColor forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor darkerColorForColor:self.navigationController.view.window.tintColor] forState:UIControlStateHighlighted];
    [_button.layer setCornerRadius:4.0f];
    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end