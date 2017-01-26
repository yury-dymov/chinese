//
//  ZhVar.h
//  chinese
//
//  Created by Dymov, Yuri on 7/28/15.
//  Copyright (c) 2015 Dymov, Yuri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhVar : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

- (void)save;

+ (ZhVar*)findByKey:(NSString*)key;

@end
