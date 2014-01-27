//
//  CRClient+Stations.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CRClient.h"
#import "CRCompletionBlocks.h"

@interface CRClient (Stations)

- (NSURLSessionDataTask *)getStationsWithCompletion:(CRArrayCompletionBlock)completion;

@end
