//
//  EmergencyViewController.m
//  Ecobici
//
//  Created by Christian Roman on 29/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "EmergencyViewController.h"

#define kPhoneNumber @"50052424"

@interface EmergencyViewController ()

@end

@implementation EmergencyViewController

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

- (IBAction)tapEmergencyButton:(UIButton *)sender
{
    NSString *url = [NSString stringWithFormat:@"%@%@", @"tel://%@", kPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
