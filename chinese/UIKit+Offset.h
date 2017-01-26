//
//  UIView+ratio.h
//  mobiliser
//
//  Created by Dymov, Yuri on 1/5/15.
//  Copyright (c) 2015 sap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Offset)

@property (nonatomic, readonly) CGFloat rightBound;
@property (nonatomic, readonly) CGFloat bottomBound;

@end

@interface UIViewController(properties)

- (NSArray*)allPropertiesOfType:(Class)type;

@end


