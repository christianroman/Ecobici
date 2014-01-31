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

/*
+ (NSValueTransformer *)sidJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return @([string integerValue]);
    } reverseBlock:^(NSNumber *sid) {
        return [NSString stringWithFormat:@"%d", [sid integerValue]];
    }];
}

+ (NSValueTransformer *)latJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return @([string doubleValue]);
    } reverseBlock:^(NSNumber *lat) {
        return [NSString stringWithFormat:@"%f", [lat doubleValue]];
    }];
}

+ (NSValueTransformer *)lngJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return @([string doubleValue]);
    } reverseBlock:^(NSNumber *lat) {
        return [NSString stringWithFormat:@"%f", [lat doubleValue]];
    }];
}

+ (NSValueTransformer *)bikesJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return @([string integerValue]);
    } reverseBlock:^(NSNumber *bikes) {
        return [NSString stringWithFormat:@"%d", [bikes integerValue]];
    }];
}

+ (NSValueTransformer *)freeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *string) {
        return @([string integerValue]);
    } reverseBlock:^(NSNumber *free) {
        return [NSString stringWithFormat:@"%d", [free integerValue]];
    }];
}

+ (id)transformedValue:(id)value
{
    return [NSNumber numberWithFloat:[value floatValue]];
}
 */

#pragma mark - MTLManagedObjectSerializing

+ (NSDictionary *)managedObjectKeysByPropertyKey
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:@"sid" forKey:@"estacion_id"];
    [dictionary setObject:@"lng" forKey:@"y"];
    [dictionary setObject:@"lat" forKey:@"x"];
    [dictionary setObject:@"name" forKey:@"nombre"];
    [dictionary setObject:@"bikes" forKey:@"bicicletas"];
    [dictionary setObject:@"free" forKey:@"lugares"];
    
    return dictionary;
}

+ (NSString *)managedObjectEntityName
{
    return NSStringFromClass([self class]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, sid: %@, name: %@, bikes: %@, free: %@>", NSStringFromClass([self class]), self, self.sid, self.name, self.bikes, self.free];
}

@end
