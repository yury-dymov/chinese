//
//  UIView+Ratio.m
//  mobiliser
//
//  Created by Santa Claus on 1/5/15.
//  Copyright (c) 2015 sap. All rights reserved.
//

#import "UIKit+Offset.h"
#import <objc/runtime.h>

@implementation UIView(Offset)

- (CGFloat)rightBound {
    return self.frame.origin.x + self.bounds.size.width;
}

- (CGFloat)bottomBound {
    return self.frame.origin.y + self.bounds.size.height;
}

@end

@implementation UIViewController(properties)

- (NSArray*)allPropertiesOfType:(Class)type {
    NSMutableArray *ret = [NSMutableArray new];
    id class = [self class];
    while (1) {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(class, &count);
        
        for (unsigned int i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
            if ([splitPropertyAttributes count] >= 2)
            {
                NSString *className = [splitPropertyAttributes objectAtIndex:1];
                if ([NSClassFromString(className) isSubclassOfClass:type]) {
                    id object = [self valueForKey:propertyName];
                    [ret addObject:object];
                }
            }
        }
        free(properties);
        if ([class respondsToSelector:@selector(superclass)]) {
            class = [class superclass];
        } else {
            break;
        }
    }
    return ret;
}

@end