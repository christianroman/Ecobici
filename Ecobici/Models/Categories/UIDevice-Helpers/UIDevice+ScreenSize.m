//
//  UIDevice+ScreenSize.m
//  UIDevice-Helpers
//
//  Created by Bruno Furtado on 13/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#import "UIDevice+ScreenSize.h"

@implementation UIDevice (ScreenSize)

- (UIDeviceScreenSize)screenSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIDeviceScreenSizePad;
    }
    
    UIDeviceScreenSize screen = UIDeviceScreenSize35Inch;
    
    if ([[UIScreen mainScreen] bounds].size.height == 568.f) {
        screen = UIDeviceScreenSize4Inch;
    }
    
    return screen;
}

@end