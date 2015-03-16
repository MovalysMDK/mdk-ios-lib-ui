/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */
//
//  MFTestHelper.m
//  addresslocation
//
//

#import "MFTestHelper.h"

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreContext.h>
#import <MFCore/MFCoreCoredata.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreCsvloader.h>
#import <MFCore/MFCoreApplication.h>

@implementation MFTestHelper

+(MFTestHelper *)getInstance{
    static MFTestHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(id) init {
    if (self = [super init]) {

    }
    return self;
}

- (void) setUpOnce {
    // initialize core data
    [self initCoreData];
    
    [[MFStarter getInstance] setupFirstLaunching];
    BOOL isFirstLaunch = [[MFStarter getInstance] isFirstLaunching];
    
    id<MFContextProtocol> mfContext = [self createContext];
    [self initCsv:mfContext firstLaunch:isFirstLaunch];
    [self saveContext: mfContext];
    
    if ( isFirstLaunch ) {
        [[MFStarter getInstance] saveFirstLaunching];
    }
}

- (void) tearDownOnce {
    // clean up core data
    [MagicalRecord cleanUp];
}

- (void) initCoreData {
    [MagicalRecord cleanUp];
    MFConfigurationHandler *configurationHandler = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    NSString *movalysDefaultModelName = [[configurationHandler getProperty:@"MovalysModelName"] getStringValue];
    NSString *dbName = [[configurationHandler getProperty:@"DatabaseName"] getStringValue];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
    if (!persistentStoreCoordinator) {
        
        NSArray *modelURLs = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:@""];
        NSMutableArray *userModels = [NSMutableArray array];
        for(NSURL *modelURL in modelURLs) {
            NSString *modelName = [modelURL lastPathComponent] ;
            NSManagedObjectModel *model = [NSManagedObjectModel MR_managedObjectModelNamed:modelName];
            BOOL isMovalysModel = [movalysDefaultModelName isEqualToString:[modelName componentsSeparatedByString:@"."][0]];
            
            if(isMovalysModel) {
                [MFCoreDataRunInit setupPersistentStoreForMovalysWithDbName:dbName andMovalysDefaultModelName:movalysDefaultModelName withModel:model];
            }
            else {
                [userModels addObject:model];
            }
            
        }
        dbName = [@"user" stringByAppendingString:dbName];
        NSManagedObjectModel *userMergedModel = [NSManagedObjectModel modelByMergingModels:userModels];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:userMergedModel];
        NSError *error = nil;
        NSDictionary *dict = [MFTestHelper MF_autoMigrationOptions];
        
        NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES) lastObject];
        NSURL *storeUrl = [NSURL fileURLWithPath:[docsDirectory stringByAppendingPathComponent:dbName]];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:dict error:&error])
        {
            [NSException raise:@"Failure setting sqlite persistent store" format:@"error: %@", error];
        }
        
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
        if([[MFCoreDataRunInit class] respondsToSelector:@selector(encrypt:)]) {
            [[MFCoreDataRunInit class] performSelector:@selector(encrypt:) withObject:storeUrl];
        }
#pragma clang diagnostic pop
        
        [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:persistentStoreCoordinator];
        [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:persistentStoreCoordinator];
    }
}

+ (NSDictionary *) MF_autoMigrationOptions
{
    // Adding the journalling mode recommended by apple
    NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
    [sqliteOptions setObject:@"WAL" forKey:@"journal_mode"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption,
                             [NSNumber numberWithBool:YES], NSSQLiteManualVacuumOption,
                             nil];
    return options;
}

-  (id<MFContextProtocol>) createContext {
    id<MFContextFactoryProtocol> contextFactory = [[MFBeanLoader getInstance] getBeanWithType:@protocol(MFContextFactoryProtocol)];
    id<MFContextProtocol> mfContext = [contextFactory createMFContextWithChildCoreDataContext];
    return mfContext;
}


- (void) initCsv:(id<MFContextProtocol>)mfContext firstLaunch:(BOOL)firstLaunch {
    
    MFFwkCsvLoaderRunInit *csvFwkRunInit = [[MFFwkCsvLoaderRunInit alloc] init];
    [csvFwkRunInit startUsingContext:mfContext firstLaunch:firstLaunch];
    
    MFProjectCsvLoaderRunInit *csvProjRunInit = [[MFProjectCsvLoaderRunInit alloc] init];
    [csvProjRunInit startUsingContext:mfContext firstLaunch:firstLaunch];
    
    MFUserCsvLoaderRunInit *csvUserRunInit = [[MFUserCsvLoaderRunInit alloc] init];
    [csvUserRunInit startUsingContext:mfContext firstLaunch:firstLaunch];
}

- (void) rollbackContext:(id<MFContextProtocol>) mfContext {
    MFCoreDataHelper *cdh = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CORE_DATA_HELPER];
    [cdh rollbackContext:mfContext];
}

- (void) saveContext:(id<MFContextProtocol>) mfContext {
    MFCoreDataHelper *cdh = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CORE_DATA_HELPER];
    [cdh saveContext:mfContext];
}

- (id) launchAction:(NSString *) actionName withInParameter:(id) parameterIn andContext:(id<MFContextProtocol>) mfContext {
    
    id res = nil;
    id<MFActionProtocol> action = [[MFBeanLoader getInstance] getBeanWithKey:actionName];
    if (action == nil) {
        @throw [[MFActionNotFound alloc]initWithName:@"Action Not Found" reason:actionName userInfo:nil];
    }
    else {
        res = [action doAction:parameterIn withContext:mfContext withQualifier:nil withDispatcher:nil];
        if ([mfContext hasError]) {
            if ([action respondsToSelector:@selector(doOnFailed:withContext:withQualifier:withDispatcher:)]) {
                [action doOnFailed:res withContext:mfContext withQualifier:nil withDispatcher:nil];
            }
        }
        else {
            if ([action respondsToSelector:@selector(doOnSuccess:withContext:withQualifier:withDispatcher:)]) {
                [action doOnSuccess:res withContext:mfContext withQualifier:nil withDispatcher:nil];
            }
        }
    }
    return res;
}

@end
