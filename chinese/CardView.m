//
//  CardView.m
//  Karten
//
//  Created by Dymov, Yuri on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CardView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "Word.h"
#import "Utils.h"

#define OFFSET 10.0

@interface CardView()

@property (nonatomic, strong) UIView *_firstSideView;
@property (nonatomic, strong) UIView *_secondSideView;
@property (nonatomic, strong) UILabel *_firstWordLabel;
@property (nonatomic, strong) UILabel *_secondTopWordLabel;
@property (nonatomic, strong) UILabel *_secondBottomWordLabel;


@end

@implementation CardView
@synthesize _firstSideView;
@synthesize _secondSideView;
@synthesize _firstWordLabel;
@synthesize _secondTopWordLabel;
@synthesize _secondBottomWordLabel;
@synthesize word;
@synthesize cardSide;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andWord:(Word *)aWord {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
        self.word = aWord;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andWord:(Word *)aWord andCardSide:(CARD_SIDE)aCardSide {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
        self.cardSide = aCardSide;
        self.word = aWord;
    }
    return self;
}

+ (NSString*)_chineseFont {
    static NSString *_chineseFont = nil;
    if (!_chineseFont) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"New Song (Ming) Typeface (Heiti TC Light) Font-Simplified Chinese" withExtension:@"ttf"];
        CFArrayRef fontDescription=CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fileURL);
        NSDictionary *dict=[(__bridge NSArray *)fontDescription objectAtIndex:0];
        _chineseFont = [dict objectForKey:@"NSFontNameAttribute"];
    }
    return _chineseFont;
}

- (void)_initView {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCardSide)]];
    [self addSubview:self._firstSideView];
    [self addSubview:self._secondSideView];
    _secondSideView.hidden = YES;
}


- (NSAttributedString*)_makeAttributesStringForTranscription:(NSString*)transcription {
    NSArray *components = [transcription componentsSeparatedByString:@" "];
    NSMutableAttributedString *ret = [NSMutableAttributedString new];
    for (NSString *component in components) {
        UIColor *underlineColor = [UIColor blackColor];
        switch ([Utils getToneFromString:component]) {
            case 1:
                underlineColor = [UIColor colorWithRed:0 green:0x81/255.f blue:0x3e/255.f alpha:1];
                break;
            case 2:
                underlineColor = [UIColor colorWithRed:0xf5/255.f green:0xd2/255.f blue:0x69/255.f alpha:1];
                break;
            case 3:
                underlineColor = [UIColor colorWithRed:0x9c/255.f green:0x12/255.f blue:0x12/255.f alpha:1];
                break;
            case 4:
                underlineColor = [UIColor colorWithRed:0 green:0x16/255.f blue:0x89/255.f alpha:1];
                break;
            default:
                break;
        }
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", component]
                                                                   attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone),
                                                                                NSForegroundColorAttributeName: underlineColor}]];
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    return ret;
}

- (void)setWord:(Word *)newWord {
    if (word != newWord) {
        word = newWord;
    }
    if (cardSide == CARD_SIDE_NATIVE) {
        self._firstWordLabel.text = word.native;
        _firstWordLabel.font = [UIFont fontWithName:[CardView _chineseFont] size:8];
        self._secondTopWordLabel.attributedText = [self _makeAttributesStringForTranscription:word.transcription];
        _secondTopWordLabel.font = [UIFont systemFontOfSize:8];
        self._secondBottomWordLabel.text = word.translation;
        _secondBottomWordLabel.font = [UIFont systemFontOfSize:8];
    } else if (cardSide == CARD_SIDE_TRANSCRIPTION) {
        self._firstWordLabel.attributedText = [self _makeAttributesStringForTranscription:word.transcription];
        _firstWordLabel.font = [UIFont systemFontOfSize:8];
        self._secondTopWordLabel.text = word.native;
        _secondTopWordLabel.font = [UIFont fontWithName:[CardView _chineseFont] size:8];
        self._secondBottomWordLabel.text = word.translation;
        _secondBottomWordLabel.font = [UIFont systemFontOfSize:8];
    } else {
        self._firstWordLabel.text = word.translation;
        _firstWordLabel.font = [UIFont systemFontOfSize:8];
        self._secondTopWordLabel.text = word.native;
        _secondTopWordLabel.font = [UIFont fontWithName:[CardView _chineseFont] size:8];
        self._secondBottomWordLabel.attributedText = [self _makeAttributesStringForTranscription:word.transcription];
        _secondBottomWordLabel.font = [UIFont systemFontOfSize:8];
    }
    [self _adjustLabel:self._firstWordLabel];
    [self _adjustLabel:self._secondTopWordLabel];
    [self _adjustLabel:self._secondBottomWordLabel];
}

- (void)setCardSide:(CARD_SIDE)aCardSide {
    if (cardSide != aCardSide) {
        cardSide = aCardSide;
        if (word)
            self.word = word;
    }
    self._firstSideView.hidden = NO;
    self._secondSideView.hidden = YES;
}

- (UIView*)_firstSideView {
    if (!_firstSideView) {
        self._firstSideView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        _firstSideView.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
        _firstSideView.layer.borderWidth = 1;
        [_firstSideView addSubview:self._firstWordLabel];
    }
    return _firstSideView;
}

- (UIView*)_secondSideView {
    if (!_secondSideView) {
        self._secondSideView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        _secondSideView.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
        _secondSideView.layer.borderWidth = 1;        
        [_secondSideView addSubview:self._secondTopWordLabel];
        [_secondSideView addSubview:self._secondBottomWordLabel];
    }
    return _secondSideView;
}

- (void)_adjustLabel:(UILabel*)lbl {
    NSInteger size = 8;
    while (1) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:lbl.font.fontName size:size]};
        CGRect rect = [lbl.text boundingRectWithSize:CGSizeMake(lbl.frame.size.width, lbl.frame.size.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
        if (rect.size.width + 5 >= lbl.frame.size.width || rect.size.height + 5 >= lbl.frame.size.height)
            break;
        ++size;
    }
    lbl.font = [UIFont fontWithName:lbl.font.fontName size:size - 1];
}

- (UILabel*)_firstWordLabel {
    if (!_firstWordLabel) {
        self._firstWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(OFFSET, OFFSET, self.frame.size.width - 2 *OFFSET, self.frame.size.height - 2 * OFFSET)];
        self._firstWordLabel.numberOfLines = 0;
        self._firstWordLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstWordLabel;
}

- (UILabel*)_secondTopWordLabel {
    if (!_secondTopWordLabel) {
        self._secondTopWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(OFFSET, OFFSET, self.frame.size.width - 2 *OFFSET, (self.frame.size.height - 2 * OFFSET)* 0.5f)];
        self._secondTopWordLabel.numberOfLines = 0;
        self._secondTopWordLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _secondTopWordLabel;
}

- (UILabel*)_secondBottomWordLabel {
    if (!_secondBottomWordLabel) {
        self._secondBottomWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(OFFSET, self._secondTopWordLabel.frame.origin.y + self._secondTopWordLabel.frame.size.height, self.frame.size.width - 2 *OFFSET, self._secondTopWordLabel.frame.size.height)];
        self._secondBottomWordLabel.numberOfLines = 0;
        self._secondBottomWordLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _secondBottomWordLabel;
}



- (void)changeCardSide {
    UIView *frontView, *backView;
    UIViewAnimationTransition transition;
    if (!_firstSideView.hidden) {
        frontView = _firstSideView;
        backView = _secondSideView;
        transition = UIViewAnimationTransitionFlipFromRight;
    } else {
        frontView = _secondSideView;
        backView = _firstSideView;
        transition = UIViewAnimationTransitionFlipFromLeft;
    }
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationTransition:transition forView:frontView cache:YES];
    frontView.hidden = YES;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"rotate2" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationTransition:transition forView:backView cache:YES];
    backView.hidden = NO;
    [UIView commitAnimations];
}


@end
