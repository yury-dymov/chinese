//
//  Utils.m
//  chinese
//
//  Created by Dymov, Yuri on 7/27/15.
//  Copyright (c) 2015 Dymov, Yuri. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)headerHeight {
    return 44 + [self statusBarHeight];
}

+ (CGFloat)buttonHeight {
    return 44;
}

+ (CGFloat)widgetHeight {
    return 44;
}

+ (CGFloat)statusBarHeight {
    return 20;
}

+ (UIColor*)buttonBorderColor {
    return [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
}

+ (UIColor*)headerColor {
    return [UIColor colorWithRed:0 green:122.0/0x100 blue:1 alpha:1];
}

+ (NSInteger)getToneFromString:(NSString *)str {
    NSArray *tones = @[
    @[@"a", @"o", @"i", @"u", @"e", @"ü"],
    @[@"ā", @"ō", @"ī", @"ū", @"ē", @"ǖ"],
    @[@"á", @"ó", @"í", @"ú", @"é", @"ǘ"],
    @[@"ǎ", @"ǒ", @"ǐ", @"ǔ", @"ě", @"ǚ"],
    @[@"à", @"ò", @"ì", @"ù", @"è", @"ǜ"]];
    for (NSInteger i = 4; i >= 0; --i) {
        for (NSString *letter in [tones objectAtIndex:i]) {
            if ([[str lowercaseString] rangeOfString:letter].location != NSNotFound) {
                return i;
            }
        }
    }
    return 0;
}

@end
