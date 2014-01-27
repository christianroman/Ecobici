//
//  Station.h
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Station : MTLModel <MTLJSONSerializing/*, MTLManagedObjectSerializing*/>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSNumber *free;
@property (nonatomic, copy, readonly) NSNumber *bikes;
@property (nonatomic, copy, readonly) NSString *principal;
@property (nonatomic, copy, readonly) NSString *secundario;
@property (nonatomic, copy, readonly) NSString *referencia;
@property (nonatomic, copy, readonly) NSString *colonia;
@property (nonatomic, copy, readonly) NSString *delegacion;
@property (nonatomic, copy, readonly) NSNumber *lat;
@property (nonatomic, copy, readonly) NSNumber *lng;
@property (nonatomic, copy, readonly) NSNumber *sid;

@end
