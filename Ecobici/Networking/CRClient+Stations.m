//
//  CRClient+Stations.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CRClient+Stations.h"
#import "CRClient+Requests.h"
#import "Station.h"
#import "ObjectBuilder.h"

@implementation CRClient (Stations)

- (NSURLSessionDataTask *)getStationsWithCompletion:(CRArrayCompletionBlock)completion
{
    NSString *path = @"ecobici.json";
    
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    return [self GET:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (!completion) {
            return;
        }
        
        if (responseObject) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                id collection = [[ObjectBuilder builder] collectionFromJSON:responseObject className:NSStringFromClass([Station class])];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(collection, nil);
                });
                
            });
            
        } else {
            completion(nil, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (completion) {
            completion(nil, error);
        }
        
    }];
}

@end
