//
//  CardView.h
//  Karten
//
//  Created by Dymov, Yuri on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Word;

typedef enum {
    CARD_SIDE_NATIVE = 0,
    CARD_SIDE_TRANSCRIPTION,
    CARD_SIDE_TRANSLATION
} CARD_SIDE;

@interface CardView : UIView

- (id)initWithFrame:(CGRect)frame andWord:(Word*)aWord;
- (id)initWithFrame:(CGRect)frame andWord:(Word*)aWord andCardSide:(CARD_SIDE)aCardSide;

@property (nonatomic, strong) Word *word;
@property (nonatomic, assign) CARD_SIDE cardSide;

@end
