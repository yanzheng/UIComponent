//
//  CoreDataManager.h
//  AnjukeBroker
//
//  Created by zheng yan on 12-5-31.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RTCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, copy) NSString *modelName;

+ (id)sharedInstance;
- (id)init;

- (NSManagedObject *)createObjectWithEntityName:(NSString *)entityName;

// sort by property
- (NSArray *)fetchObjectsWithEntity:(NSString *)entityName 
                           predicate:(NSString *)predicateName 
                                sort:(NSString *)sortName 
                           ascending:(BOOL)ascending; 

// sort by multiple properties
- (NSArray *)fetchObjectsWithEntity:(NSString *)entityName 
                          predicate:(NSString *)predicateName 
                            sortArr:(NSArray *)sortNameArr 
                       ascendingArr:(NSArray *)ascendingArr; 

- (void)deleteManagedObject:(NSManagedObject *)object;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
