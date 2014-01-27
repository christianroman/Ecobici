//
//  Station.m
//  Ecobici
//
//  Created by Christian Roman on 25/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "Station.h"

@implementation Station

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"sid" : @"id",
             @"principal" : @"principal",
             @"secundario" : @"secundario",
             @"referencia" : @"referencia",
             @"colonia" : @"colonia",
             @"delegacion" : @"delegacion",
             @"lng" : @"longitud",
             @"lat" : @"latitud",
             @"name" : @"nombre",
             @"bikes" : @"bicicletas",
             @"free" : @"lugares"
             };
}

#pragma mark - MTLManagedObjectSerializing
/*
+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:@"name" forKey:@"name"];
    [dictionary setObject:@"principal" forKey:@"principal"];
    [dictionary setObject:@"secundario" forKey:@"secundario"];
    [dictionary setObject:@"referencia" forKey:@"referencia"];
    [dictionary setObject:@"colonia" forKey:@"colonia"];
    [dictionary setObject:@"delegacion" forKey:@"delegacion"];
    [dictionary setObject:@"lat" forKey:@"lat"];
    [dictionary setObject:@"lng" forKey:@"lng"];
    [dictionary setObject:@"sid" forKey:@"id"];
    [dictionary setObject:@"name" forKey:@"name"];
    [dictionary setObject:@"bikes" forKey:@"bicicletas"];
    [dictionary setObject:@"free" forKey:@"lugares"];
    
    [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"status"];
    
    return dictionary;
}

+ (NSString *)managedObjectEntityName
{
    return NSStringFromClass([self class]);
}
 */

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, sid: %@, name: %@, bikes: %@, free: %@>", NSStringFromClass([self class]), self, self.sid, self.name, self.bikes, self.free];
}

@end
