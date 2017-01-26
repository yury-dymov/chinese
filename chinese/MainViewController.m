//
//  MainViewController.m
//  Karten
//
//  Created by Dymov, Yuri on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "BlocksKit+UIKit.h"
#import "UIKit+Offset.h"
#import "SyncEngine.h"
#import "CardView.h"
#import "Word.h"
#import "Topic.h"
#import "Utils.h"

#define SIDE_VIEW_SIZE 0.625

@interface MainViewController() {
    NSMutableArray *_words;
}

@property (nonatomic, strong) UIButton *_removeButton;
@property (nonatomic, strong) UIButton *_favButton;
@property (nonatomic, strong) UIButton *_menuButton;
@property (nonatomic, strong) UIButton *_addWordsButton;
@property (nonatomic, strong) UIView *_sideMenuView;
@property (nonatomic, strong) UITableView *_topicTableView;
@property (nonatomic, strong) NSArray *_topics;
@property (nonatomic, strong) NSMutableDictionary *_selectedRows;
@property (nonatomic, strong) UIView *_navigationView;
@property (nonatomic, strong) UIView *_sideMenuNavigationView;
@property (nonatomic, strong) UILabel *_sideMenuLabel;
@property (nonatomic, strong) UILabel *_titleLabel;
@property (nonatomic, strong) UIView *_contentView;
@property (nonatomic, strong) InfPagedScrollView *_cardScrollView;
@property (nonatomic, strong) UISegmentedControl *_langSegmentControl;
@property (nonatomic, strong) UIRefreshControl *_refreshControl;

@end

@implementation MainViewController
@synthesize _addWordsButton;
@synthesize _cardScrollView;
@synthesize _removeButton;
@synthesize _sideMenuView;
@synthesize _topicTableView;
@synthesize _selectedRows;
@synthesize _navigationView;
@synthesize _menuButton;
@synthesize _favButton;
@synthesize _sideMenuLabel;
@synthesize _sideMenuNavigationView;
@synthesize _titleLabel;
@synthesize _contentView;
@synthesize _langSegmentControl;
@synthesize _topics;
@synthesize _refreshControl;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _words = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"syncDone" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [_refreshControl endRefreshing];
            BOOL success = [note.object boolValue];
            self._topics = [Topic findAll];
            [_topicTableView reloadData];
            if (success) {
//                [[[UIAlertView alloc] initWithTitle:@"Успех!" message:@"Данные обновлены" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Ошибка!" message:@"Подключиться к серверу не получилось" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"wordFavChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            Word *changedWord = note.object;
            for (NSUInteger i = 0; i < _words.count; ++i) {
                Word *word = [_words objectAtIndex:i];
                if (changedWord.id_ == word.id_) {
                    word.isFavorite = changedWord.isFavorite;
                    if (i == _cardScrollView.currentIndex) {
                        [self _updateFavButtonState];
                    }
                    break;
                }
            }
        }];
        self._topics = [Topic findAll];
        self._selectedRows = [NSMutableDictionary new];
        self.title = @"Карточки";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"cards"] tag:0];
    }
    return self;
}

- (void)setTitle:(NSString *)atitle {
    [super setTitle:atitle];
    self._titleLabel.text = atitle;
}

- (CGFloat)_cardSideLength {
    static CGFloat ret = 0;
    if (!ret ) {
        ret = [UIScreen mainScreen].bounds.size.height * 0.4;
    }
    return ret;
}

- (CGFloat)_sideMenuWidth {
    static CGFloat ret = 0;
    if (fabs(ret) < 0.00001)
        ret = [Utils screenWidth] * SIDE_VIEW_SIZE;
    return ret;
}

- (UIButton*)_favButton {
    if (!_favButton) {
        self._favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"star-filled"] forState:UIControlStateSelected];
        _favButton.frame = CGRectMake(_navigationView.frame.size.width - [Utils buttonHeight], [Utils statusBarHeight], [Utils buttonHeight], [Utils buttonHeight]);
        [_favButton bk_addEventHandler:^(id sender) {
            Word *word = [_words objectAtIndex:_cardScrollView.currentIndex];
            word.isFavorite = !word.isFavorite;
            _favButton.selected = word.isFavorite;
            [word save];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wordFavChanged" object:word];
        } forControlEvents:UIControlEventTouchUpInside];
        [self _updateFavButtonState];
    }
    return _favButton;
}



- (UIButton*)_menuButton {
    if (!_menuButton) {
        self._menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(0, [Utils statusBarHeight], [Utils buttonHeight], [Utils buttonHeight]);
        [_menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(_toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (UIButton*)_removeButton {
    if (!_removeButton) {
        self._removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat offset = [Utils screenWidth] / 6;
        CGFloat yoffset = (self.view.frame.size.height - _cardScrollView.bottomBound - [Utils buttonHeight]) * 0.5f;
        _removeButton.frame = CGRectMake(offset, _cardScrollView.bottomBound + yoffset, [Utils screenWidth] - 2 * offset, [Utils buttonHeight]);
        [_removeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_removeButton setTitle:@"Убрать" forState:UIControlStateNormal];
        _removeButton.layer.borderColor = [Utils buttonBorderColor].CGColor;
        _removeButton.layer.borderWidth = 1;
        if (!_words.count)
            _removeButton.hidden = YES;
        [_removeButton bk_addEventHandler:^(id sender) {
            if (_words.count) {
                [_words removeObjectAtIndex:[_cardScrollView currentIndex]];
                [_cardScrollView reloadData];
                if (!_words.count) {
                    _removeButton.hidden = YES;
                }
                [self _updateFavButtonState];                
            }
        } forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateBegan) {
                UIActionSheet *sheet = [UIActionSheet new];
                [sheet bk_setDestructiveButtonWithTitle:@"Убрать все" handler:^{
                    [_words removeAllObjects];
                    _removeButton.hidden = YES;
                    [self._cardScrollView reloadData];
                }];
                [sheet bk_addButtonWithTitle:@"Перемешать" handler:^{
                    [self randomize:_words];
                    [self._cardScrollView reloadData];
                }];
                [sheet bk_setCancelButtonWithTitle:@"Отмена" handler:^{
                
                }];
                [sheet showInView:self.view];
            }
        }];
        [_removeButton addGestureRecognizer:longPress];
    }
    return _removeButton;
}

- (UISegmentedControl*)_langSegmentControl {
    if (!_langSegmentControl) {
        self._langSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Иероглифы", @"Pinyin", @"Перевод"]];
        CGFloat offset = ([Utils screenWidth] - _langSegmentControl.frame.size.width) * 0.5f;
        _langSegmentControl.frame = CGRectMake(offset, _navigationView.bottomBound + self.view.frame.size.height * 0.05, _langSegmentControl.frame.size.width, _langSegmentControl.frame.size.height);
        _langSegmentControl.selectedSegmentIndex = 0;
        [_langSegmentControl bk_addEventHandler:^(id sender) {
            for (CardView *cardView in _cardScrollView.allObjects) {
                if ([cardView isKindOfClass:[CardView class]]) {
                    cardView.cardSide = (CARD_SIDE)_langSegmentControl.selectedSegmentIndex;
                }
            }
            
        } forControlEvents:UIControlEventValueChanged];
    }
    return _langSegmentControl;
}

- (UILabel*)_titleLabel {
    if (!_titleLabel) {
        self._titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([Utils buttonHeight] + 10, [Utils statusBarHeight], [Utils screenWidth] - 2 * [Utils buttonHeight] - 20, [Utils buttonHeight])];
        _titleLabel.font = [UIFont systemFontOfSize:22];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = self.title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel*)_sideMenuLabel {
    if (!_sideMenuLabel) {
        self._sideMenuLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [Utils statusBarHeight], [self _sideMenuWidth] - 20, [Utils buttonHeight])];
        _sideMenuLabel.font = [UIFont systemFontOfSize:22];
        _sideMenuLabel.textColor = [UIColor whiteColor];
        _sideMenuLabel.textAlignment = NSTextAlignmentCenter;
        _sideMenuLabel.text = @"Темы";
    }
    return _sideMenuLabel;
}


- (UIView*)_navigationView {
    if (!_navigationView) {
        self._navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Utils screenWidth], [Utils headerHeight])];
        _navigationView.backgroundColor = [Utils headerColor];
        [_navigationView addSubview:self._titleLabel];
        [_navigationView addSubview:self._menuButton];
        [_navigationView addSubview:self._favButton];
    }
    return _navigationView;
}

- (void)_updateFavButtonState {
    if (_words.count) {
        Word *currentWord = [_words objectAtIndex:_cardScrollView.currentIndex];
        _favButton.selected = currentWord.isFavorite;
    }
    _favButton.hidden = !_words.count;
}

- (InfPagedScrollView*)_cardScrollView {
    if (!_cardScrollView) {
        self._cardScrollView = [[InfPagedScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.33, [Utils screenWidth], [self _cardSideLength])];
        _cardScrollView.dataSource = self;
        [_cardScrollView bk_addEventHandler:^(id sender) {
            [self _updateFavButtonState];
        } forControlEvents:UIControlEventValueChanged];
    }
    return _cardScrollView;
}

- (UITableView*)_topicTableView {
    if (!_topicTableView) {
        self._topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [Utils headerHeight], [Utils screenWidth] * SIDE_VIEW_SIZE, self.view.frame.size.height - [Utils headerHeight] - [Utils buttonHeight] - 50)];
        _topicTableView.dataSource = self;
        _topicTableView.delegate = self;
        
        self._refreshControl = [[UIRefreshControl alloc] init];
        [_topicTableView addSubview:_refreshControl];
        [_refreshControl bk_addEventHandler:^(id sender) {
            [[SyncEngine getInstance] xmit];
        } forControlEvents:UIControlEventValueChanged];
    }
    return _topicTableView;
}

- (UIView*)_sideMenuNavigationView {
    if (!_sideMenuNavigationView) {
        self._sideMenuNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self _sideMenuWidth], self._navigationView.frame.size.height)];
        _sideMenuNavigationView.backgroundColor = [UIColor lightGrayColor];
        [_sideMenuNavigationView addSubview:self._sideMenuLabel];
    }
    return _sideMenuNavigationView;
}

- (UIView*)_sideMenuView {
    if (!_sideMenuView) {
        self._sideMenuView = [[UIView alloc] initWithFrame:CGRectMake(-[self _sideMenuWidth], 0, [self _sideMenuWidth], self.view.frame.size.height)];
        [_sideMenuView addSubview:self._sideMenuNavigationView];
        [_sideMenuView addSubview:self._topicTableView];
        [_sideMenuView addSubview:self._addWordsButton];
    }
    return _sideMenuView;
}

- (UIButton*)_addWordsButton {
    if (!_addWordsButton) {
        self._addWordsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat offset = [self _sideMenuWidth] / 6;
        _addWordsButton.frame = CGRectMake(offset, self._topicTableView.bottomBound + 20, [self _sideMenuWidth] - 2 * offset, [Utils buttonHeight]);
        [_addWordsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addWordsButton setTitle:@"Добавить" forState:UIControlStateNormal];
        _addWordsButton.layer.borderColor = [Utils buttonBorderColor].CGColor;
        _addWordsButton.layer.borderWidth = 1;
        [_addWordsButton bk_addEventHandler:^(id sender) {
            NSMutableArray *newWords = [NSMutableArray new];
            for (Topic *topic in _selectedRows.allValues) {
                [newWords addObjectsFromArray:topic.words];
            }
            [self randomize:newWords];
            [_words addObjectsFromArray:newWords];
            [_cardScrollView reloadData];
            if (_words.count) {
                _removeButton.hidden = NO;
                _favButton.hidden = NO;
            }
            [_selectedRows removeAllObjects];
            [_topicTableView reloadData];
            [self _toggleMenu];
            [self _updateFavButtonState];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _addWordsButton;
}

- (void)_toggleMenu {
    if (self._contentView.frame.origin.x < 1.0f) {
        [UIView animateWithDuration:0.6 animations:^{
            self._contentView.frame = CGRectMake([self _sideMenuWidth], 0, self.view.frame.size.width, self.view.frame.size.height);
            self._sideMenuView.frame = CGRectMake(0, 0, _sideMenuView.frame.size.width, _sideMenuView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.6 animations:^{
            self._contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self._sideMenuView.frame = CGRectMake(-_sideMenuView.frame.size.width, 0, _sideMenuView.frame.size.width, _sideMenuView.frame.size.height);
        }];
    }
}


- (void)randomize:(NSMutableArray*)anArray {
    NSInteger count = [anArray count];
    for (NSInteger i = 0; i < count - 1; i++)
    {
        NSInteger swap = arc4random() % (count - i) + i;
        [anArray exchangeObjectAtIndex:swap withObjectAtIndex:i];
    }
}


- (UIView*)_contentView {
    if (!_contentView) {
        self._contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_contentView addSubview:self._navigationView];
        [_contentView addSubview:self._langSegmentControl];
        [_contentView addSubview:self._cardScrollView];
        [_contentView addSubview:self._removeButton];
    }
    return _contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [Utils screenHeight] - self.tabBarController.tabBar.frame.size.height);
    [self.view addSubview:self._contentView];
    [self.view addSubview:self._sideMenuView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _updateFavButtonState];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self._topics.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    Topic *topic = [self._topics objectAtIndex:indexPath.row];
    cell.textLabel.text = topic.title;
    if ([_selectedRows valueForKey:topic.title])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedRows setValue:[self._topics objectAtIndex:indexPath.row] forKey:cell.textLabel.text];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedRows removeObjectForKey:cell.textLabel.text];
    }
}

- (NSUInteger)numberOfPagesInInfPagedScrollView:(InfPagedScrollView *)infPagedScrollView {
    return _words.count;
}

- (UIView*)infPagedScrollView:(InfPagedScrollView *)infPagedScrollView viewAtIndex:(NSUInteger)idx reusableView:(UIView *)view {
    CardView *cv = (id)view;
    if (!cv)
        cv = [[CardView alloc] initWithFrame:CGRectMake(0, 0, [self _cardSideLength], [self _cardSideLength])];
    cv.cardSide = (CARD_SIDE)_langSegmentControl.selectedSegmentIndex;            
    cv.word = [_words objectAtIndex:idx];
    return cv;
}


@end
