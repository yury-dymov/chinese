//
//  PopupViewController.m
//  chinese
//
//  Created by Dymov, Yuri on 10/15/15.
//  Copyright © 2015 Dymov, Yuri. All rights reserved.
//

#import "PopupViewController.h"
#import <STPopup/STPopup.h>
#import "CardView.h"

#define CARD_SIZE 0.625

@interface PopupViewController ()

@property (nonatomic, strong) CardView *_cardView;

@end

@implementation PopupViewController
@synthesize word;
@synthesize _cardView;

- (CGFloat)_cardSize {
    return [UIScreen mainScreen].bounds.size.width * CARD_SIZE;
}

- (id)init {
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (id)initWithWord:(Word *)aWord {
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        self.word = aWord;
    }
    return self;
}

- (CardView*)_cardView {
    if (!_cardView) {
        self._cardView = [[CardView alloc] initWithFrame:CGRectMake(0, 0, [self _cardSize], [self _cardSize]) andWord:word andCardSide:CARD_SIDE_NATIVE];
    }
    return _cardView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_cardView.superview) {
        [self.view addSubview:self._cardView];
    }
    _cardView.frame = CGRectMake((self.contentSizeInPopup.width - [self _cardSize]) * .5f, (self.contentSizeInPopup.height - [self _cardSize]) * .5f, [self _cardSize], [self _cardSize]);
}

- (void)setWord:(Word *)aword {
    if (word != aword) {
        word = aword;
    }
    _cardView.word = aword;
}

- (void)_toggleFavorite {
    self.word.isFavorite = !self.word.isFavorite;
    [self.word save];
    [self _updateTabBarItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wordFavChanged" object:word];        
}

- (void)_updateTabBarItem {
    if (self.word.isFavorite) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star-filled"] style:UIBarButtonItemStylePlain target:self action:@selector(_toggleFavorite)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStylePlain target:self action:@selector(_toggleFavorite)];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _updateTabBarItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
