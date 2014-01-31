//
//  AboutViewController.m
//  Ecobici
//
//  Created by Christian Roman on 29/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "AboutViewController.h"
#import "UIColor+Utilities.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDataSourceDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger row = [indexPath row];
    if ([indexPath section] == 0) {
        switch (row) {
            case 0:
                cell.textLabel.text = @"Sitio Oficial de Ecobici";
                break;
            case 1:
                cell.textLabel.text = @"Siguenos en Twitter";
                break;
            case 2: {
                cell.textLabel.text = @"Compartir";
                break;
            }
            default:
                break;
        }
    } else if ([indexPath section] == 1) {
        switch (row) {
            case 0:
                cell.textLabel.text = @"Escribe una opinión en App Store";
                break;
            default:
                break;
        }
    } else {
        if (row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Version: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        } else {
            cell.textLabel.text = @"Desarrollador";
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Social";
        case 1:
            return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0: {
                NSString* launchUrl = @"http://www.ecobici.df.gob.mx";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
                break;
            }
            case 1: {
                NSString* launchUrl = @"twitter://user?screen_name=ecobiciplus";
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:launchUrl]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ecobiciplus"]];
                }
                break;
            }
            case 2: {
                NSString *stringShare = @"Estoy usando @ecobiciplus para planear mis viajes de #Ecobici, pruebalo. http://ow.ly/hMiBa";
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[stringShare] applicationActivities:nil];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    } else if([indexPath section] == 1) {
        switch ([indexPath row]) {
            case 0: {
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=592821826"]];
                break;
            }
            case 1: {
                break;
            }
            default:
                break;
        }
    } else {
        if ([indexPath row] == 1) {
            NSString* launchUrl = @"twitter://user?screen_name=chroman";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:launchUrl]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/chroman"]];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
 
@end
