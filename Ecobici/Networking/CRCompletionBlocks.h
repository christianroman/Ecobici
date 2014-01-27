//
//  CRCompletionBlocks.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

typedef void (^CRCompletionBlock)(NSError *error);

typedef void (^CRResponseCompletionBlock)(NSHTTPURLResponse *response, id responseObject, NSError *error);

typedef void (^CRBooleanCompletionBlock)(BOOL result, NSError *error);

typedef void (^CRObjectCompletionBlock)(id object, NSError *error);

typedef void (^CRArrayCompletionBlock)(NSArray *collection, NSError *error);
