//
//  MSMenuViewController.m
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSMenuViewController.h"
#import "MSMenuTableViewHeader.h"
#import "MSMenuCell.h"

#import "StationsViewController.h"
#import "FavoritesViewController.h"
#import "EmergencyViewController.h"
#import "RoutesViewController.h"
#import "TravelsViewController.h"
#import "FAQViewController.h"
#import "AboutViewController.h"

NSString * const MSMenuCellReuseIdentifier = @"Drawer Cell";
NSString * const MSDrawerHeaderReuseIdentifier = @"Drawer Header";

typedef NS_ENUM(NSUInteger, MSMenuViewControllerTableViewSectionType) {
    MSMenuViewControllerTableViewSectionTypeEcobici,
    MSMenuViewControllerTableViewSectionTypePersonal,
    MSMenuViewControllerTableViewSectionTypeAbout,
    MSMenuViewControllerTableViewSectionTypeCount
};

@interface MSMenuViewController ()

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
#if defined(STORYBOARD)
@property (nonatomic, strong) NSDictionary *paneViewControllerIdentifiers;
#else
@property (nonatomic, strong) NSDictionary *paneViewControllerClasses;
#endif
@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;
@property (nonatomic, strong) NSDictionary *sectionTitles;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;

@property (nonatomic, strong) UIBarButtonItem *paneStateBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *paneRevealLeftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *paneRevealRightBarButtonItem;

@end

@implementation MSMenuViewController

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[MSMenuCell class] forCellReuseIdentifier:MSMenuCellReuseIdentifier];
    [self.tableView registerClass:[MSMenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:MSDrawerHeaderReuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.25];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - MSMenuViewController

- (void)initialize
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = @{
        @(MSPaneViewControllerTypeStations) : @"Estaciones",
        @(MSPaneViewControllerTypeRoutes) : @"Rutas",
        @(MSPaneViewControllerTypeEmergency) : @"Emergencia",
        @(MSPaneViewControllerTypeFavorites) : @"Favoritos",
        @(MSPaneViewControllerTypeTravels) : @"Mis viajes",
        @(MSPaneViewControllerTypeFAQ) : @"FAQ",
        @(MSPaneViewControllerTypeAbout) : @"Acerca de"
    };
    self.paneViewControllerClasses = @{
        @(MSPaneViewControllerTypeStations) : [StationsViewController class],
        @(MSPaneViewControllerTypeRoutes) : [RoutesViewController class],
        @(MSPaneViewControllerTypeEmergency) : [EmergencyViewController class],
        @(MSPaneViewControllerTypeFavorites) : [FavoritesViewController class],
        @(MSPaneViewControllerTypeTravels) : [TravelsViewController class],
        @(MSPaneViewControllerTypeFAQ) : [FAQViewController class],
        @(MSPaneViewControllerTypeAbout) : [AboutViewController class]
    };
    self.sectionTitles = @{
        @(MSMenuViewControllerTableViewSectionTypeEcobici) : @"Ecobici",
        @(MSMenuViewControllerTableViewSectionTypePersonal) : @"Personal",
        @(MSMenuViewControllerTableViewSectionTypeAbout) : @"Info",
    };
    
    self.tableViewSectionBreaks = @[
        @(MSPaneViewControllerTypeFavorites),
        @(MSPaneViewControllerTypeFAQ),
        @(MSPaneViewControllerTypeCount)
    ];
}

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    if (indexPath.section == 0) {
        paneViewControllerType = indexPath.row;
    } else {
        paneViewControllerType = ([self.tableViewSectionBreaks[(indexPath.section - 1)] integerValue] + indexPath.row);
    }
    NSAssert(paneViewControllerType < MSPaneViewControllerTypeCount, @"Invalid Index Path");
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType
{
    // Close pane if already displaying the pane view controller
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    
    Class paneViewControllerClass = self.paneViewControllerClasses[@(paneViewControllerType)];
    UIViewController *paneViewController = (UIViewController *)[paneViewControllerClass new];
    
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    self.paneRevealLeftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Left Reveal Icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
    paneViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
     
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSMenuViewControllerTableViewSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.tableViewSectionBreaks[section] integerValue];
    } else {
        return ([self.tableViewSectionBreaks[section] integerValue] - [self.tableViewSectionBreaks[(section - 1)] integerValue]);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:MSDrawerHeaderReuseIdentifier];
    headerView.textLabel.text = self.sectionTitles[@(section)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new]; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMenuCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.paneViewControllerTitles[@([self paneViewControllerTypeForIndexPath:indexPath])];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:paneViewControllerType];
    
    // Prevent visual display bug with cell dividers
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)state
{
    // Ensure that the pane's table view can scroll to top correctly
    self.tableView.scrollsToTop = (state == MSDynamicsDrawerPaneStateOpen);
}

@end
