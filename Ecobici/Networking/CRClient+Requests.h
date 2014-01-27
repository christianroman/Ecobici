//
//  CRClient+Requests.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CRClient.h"
#import "CRCompletionBlocks.h"

@interface CRClient (Requests)

- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                 completion:(CRResponseCompletionBlock)completion;

@end
