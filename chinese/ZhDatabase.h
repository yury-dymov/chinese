//
//  PFDatabase.h
//  Partner Finder
//
//  Created by Dymov, Yuri on 3/11/15.
//  Copyright (c) 2015 IBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EGODatabase/EGODatabase.h>

@interface ZhDatabase : NSObject

+ (id)getInstance;
- (EGODatabaseResult*)executeQuery:(NSString*)query;
- (EGODatabaseResult*)executeQuery:(NSString *)query parameters:(NSArray*)parameters;

@end
