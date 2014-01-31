//
//  CRCoreDataController.h
//  Ecobici
//
//  Created by Christian Roman on 29/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRCoreDataController : NSObject

+ (id)sharedInstance;

- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *)masterManagedObjectContext;
- (NSManagedObjectContext *)backgroundManagedObjectContext;
- (NSManagedObjectContext *)newManagedObjectContext;
- (void)saveMasterContext;
- (void)saveBackgroundContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
