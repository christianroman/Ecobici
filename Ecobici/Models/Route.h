//
//  Route.h
//  Ecobici
//
//  Created by Christian Roman on 31/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, strong) NSArray *coordinates;

@end
