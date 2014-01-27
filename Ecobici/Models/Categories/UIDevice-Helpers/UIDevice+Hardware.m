//
//  UIDevice+Hardware.m
//  UIDevice-Helpers
//
//  Created by Bruno Furtado on 13/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#include <sys/sysctl.h>
#import "UIDevice+Hardware.h"

static NSString *const kPod = @"iPod";
static NSString *const kPhone = @"iPhone";
static NSString *const kPad = @"iPad";

static NSInteger SupportedModel;
static NSString* ModelVersion;

@implementation UIDevice (Hardware)

#pragma mark -
#pragma mark - UIDevice

- (id)init
{
    self = [super init];
    
    if (self) {
        SupportedModel = -1;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Public methods

- (BOOL)isSupportedOS7Features
{
    if (SupportedModel != -1)
        return SupportedModel;
    
    if ([self modelVersion]) {
        SupportedModel = NO;
        NSString *stringVersion = nil;
        
        if ([[self modelVersion] rangeOfString:kPod].location != NSNotFound) {
            stringVersion = [[self modelVersion] stringByReplacingOccurrencesOfString:kPod withString:@""];
            SupportedModel = ([stringVersion integerValue] >= UIDeviceModelPod5);
        }
        
        else if ([[self modelVersion] rangeOfString:kPhone].location != NSNotFound) {
            stringVersion = [[self modelVersion] stringByReplacingOccurrencesOfString:kPhone withString:@""];
            SupportedModel = ([stringVersion integerValue] >= UIDeviceModelPhone4S);
        }
        
        else if ([[self modelVersion] rangeOfString:kPad].location != NSNotFound) {
            stringVersion = [[self modelVersion] stringByReplacingOccurrencesOfString:kPad withString:@""];
            SupportedModel = ([stringVersion integerValue] >= UIDeviceModelPad3);
        }
    }
    
    return SupportedModel;
}

- (NSString *)modelVersion
{
    if (!ModelVersion) {
        size_t size;
        char *model;
        
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        model = malloc(size);
        sysctlbyname("hw.machine", model, &size, NULL, 0);
        
        ModelVersion = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
        free(model);
        
        if ([ModelVersion rangeOfString:kPod options:NSCaseInsensitiveSearch].location == NSNotFound
            && [ModelVersion rangeOfString:kPhone options:NSCaseInsensitiveSearch].location == NSNotFound
            && [ModelVersion rangeOfString:kPad options:NSCaseInsensitiveSearch].location == NSNotFound) {
            ModelVersion = [self model];
        }
    }
    
#ifdef NZDEBUG
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, ModelVersion);
#endif
    
    return ModelVersion;
}

@end