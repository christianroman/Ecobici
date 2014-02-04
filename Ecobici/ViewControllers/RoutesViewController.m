//
//  RoutesViewController.m
//  Ecobici
//
//  Created by Christian Roman on 31/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "RoutesViewController.h"
#import "RouteDetailViewController.h"
#import "Route.h"
#import "MRProgress.h"
#import "CRClient+FileDownload.h"

#define kFilePath   @"ciclovias.json"

@import CoreLocation;

@interface RoutesViewController ()

@property (nonatomic, strong) NSMutableArray *routes;

@end

@implementation RoutesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)downloadRoutesFile
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    NSURL *URL = [NSURL URLWithString:@"http://chroman.me/ciclovias.json"];
    [[CRClient sharedClient] downloadFileFromURL:URL completion:^(NSURL *localURL, NSError *error) {
        
        NSData *JSONData = nil;
        if (!error) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *newURL = [NSURL URLWithString:@"ciclovias_cloud.json" relativeToURL:[localURL URLByDeletingLastPathComponent]];
            if ([fileManager fileExistsAtPath:[newURL path] isDirectory:NULL]) {
                [fileManager removeItemAtURL:newURL error:NULL];
                [fileManager moveItemAtURL:localURL toURL:newURL error:NULL];
                [fileManager removeItemAtURL:localURL error:NULL];
            } else {
                [fileManager moveItemAtURL:localURL toURL:newURL error:NULL];
            }
            JSONData = [NSData dataWithContentsOfURL:newURL];
        } else {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ciclovias" ofType:@"json"];
            JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
        }
        id JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
        [self loadRoutesFromJSON:JSONObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
        });
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadRoutesFile];
}

#pragma mark - Class methods

- (void)loadRoutesFromJSON:(id)JSONObject
{
    _routes = [[NSMutableArray alloc] init];
    NSArray *features = [JSONObject objectForKey:@"features"];
    
    for (NSDictionary *feature in features) {
        Route *route = [[Route alloc] init];
        route.type = [[feature objectForKey:@"type"] integerValue];
        route.name = [[feature objectForKey:@"properties"] objectForKey:@"name"];
        route.description = [[feature objectForKey:@"properties"] objectForKey:@"description"];
        route.coordinates = [feature objectForKey:@"coordinates"];
        [_routes addObject:route];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Route *route = [_routes objectAtIndex:[indexPath row]];
    [cell.textLabel setText:route.name];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Route *route = [_routes objectAtIndex:[indexPath row]];
    RouteDetailViewController *detailViewController = [[RouteDetailViewController alloc] init];
    [detailViewController setRoute:route];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
