//
//  Utils.h
//  chinese
//
//  Created by Dymov, Yuri on 7/27/15.
//  Copyright (c) 2015 Dymov, Yuri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;
+ (CGFloat)headerHeight;
+ (CGFloat)buttonHeight;
+ (CGFloat)statusBarHeight;
+ (CGFloat)widgetHeight;

+ (UIColor*)buttonBorderColor;
+ (UIColor*)headerColor;

+ (NSInteger)getToneFromString:(NSString*)str;


@end
