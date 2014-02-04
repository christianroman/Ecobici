//
//  FavoritesViewController.m
//  Ecobici
//
//  Created by Christian Roman on 28/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "Station.h"
#import "DetailViewController.h"

@import CoreData;

@interface FavoritesViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *favoriteStations;

@end

@implementation FavoritesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadFavorites
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[Station managedObjectEntityName]
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError* error;
    _favoriteStations = [[NSMutableArray alloc] initWithArray:[_managedObjectContext executeFetchRequest:fetchRequest error:&error]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFavorites];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    static BOOL firstTime = YES;
    if (!firstTime) {
        [self loadFavorites];
        [self.tableView reloadData];
    }
    firstTime = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_favoriteStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Station *station = (Station *)[_favoriteStations objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:station.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Station *station = (Station *)[_favoriteStations objectAtIndex:[indexPath row]];
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    [detailViewController setStation:station];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *stationManagedObject = [_favoriteStations objectAtIndex:[indexPath row]];
        [_favoriteStations removeObject:stationManagedObject];
        [_managedObjectContext deleteObject:stationManagedObject];
        [_managedObjectContext save:nil];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

@end
