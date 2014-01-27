//
//  UIDevice+System.m
//  UIDevice-Helpers
//
//  Created by Bruno Furtado on 13/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#import "UIDevice+System.h"

@implementation UIDevice (System)

- (BOOL)isSystemGreaterOS5
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_0);
}

- (BOOL)isSystemGreaterOS6
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_0);
}

@end