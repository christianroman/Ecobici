//
//  CRClient.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "AFNetworking.h"

@interface CRClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
