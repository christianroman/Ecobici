//
//  UIDevice+Hardware.h
//  UIDevice-Helpers
//
//  Created by Bruno Furtado on 13/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIDeviceModelPod) {
    UIDeviceModelPod5 = 5
};

typedef NS_ENUM(NSInteger, UIDeviceModelPhone) {
    UIDeviceModelPhone4S = 4
};

typedef NS_ENUM(NSInteger, UIDeviceModelPad) {
    UIDeviceModelPad3 = 3
};

@interface UIDevice (Hardware)

- (BOOL)isSupportedOS7Features;
- (NSString *)modelVersion;

@end
