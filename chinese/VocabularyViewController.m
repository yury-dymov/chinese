//
//  VocabularyViewController.m
//  chinese
//
//  Created by Dymov, Yuri on 8/1/15.
//  Copyright (c) 2015 Dymov, Yuri. All rights reserved.
//

#import "VocabularyViewController.h"
#import "UIKit+Offset.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "Utils.h"
#import "Word.h"
#import <STPopup/STPopup.h>
#import "PopupViewController.h"

enum {
    VOC_RUSSIAN = 0,
    VOC_PINYIN = 1
};

@interface VocabularyViewController () {
    BOOL _keyboardIsVisible;
}

@property (nonatomic, strong) UISegmentedControl *_filterSegmentControl;
@property (nonatomic, strong) UISearchBar *_searchBar;
@property (nonatomic, strong) UITableView *_wordTableView;
@property (nonatomic, strong) UIView *_navigationView;
@property (nonatomic, strong) UILabel *_titleLabel;
@property (nonatomic, strong) NSArray *_words;

@end

@implementation VocabularyViewController

@synthesize _filterSegmentControl;
@synthesize _searchBar;
@synthesize _words;
@synthesize _wordTableView;
@synthesize _titleLabel;
@synthesize _navigationView;


- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"syncDone" object:nil];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            _keyboardIsVisible = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            _keyboardIsVisible = NO;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"wordFavChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            Word *changedWord = note.object;
            if (_wordTableView) {
                for (NSUInteger i = 0; i < _words.count; ++i) {
                    Word *word = [_words objectAtIndex:i];
                    if (word.id_ == changedWord.id_) {
                        word.isFavorite = changedWord.isFavorite;
                        [_wordTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
        }];
        self.title = @"Словарь";        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"book"] tag:1];
    }
    return self;
}

- (void)_filterWords {
    self._words = [self._words sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (_filterSegmentControl.selectedSegmentIndex == VOC_RUSSIAN)
            return [[obj1 translation] compare:[obj2 translation] options:NSCaseInsensitiveSearch];
        else
            return [[obj1 transcription] compare:[obj2 transcription] options:NSCaseInsensitiveSearch];
    }];
}

- (void)_loadData {
    self._words = [Word findAll];
    [self _filterWords];
    [self._wordTableView reloadData];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self._titleLabel.text = title;
}

- (UILabel*)_titleLabel {
    if (!_titleLabel) {
        self._titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([Utils buttonHeight] + 10, [Utils statusBarHeight], [Utils screenWidth] - 2 * ([Utils buttonHeight] + 10), [Utils headerHeight] - [Utils statusBarHeight])];
        _titleLabel.font = [UIFont systemFontOfSize:22];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIView*)_navigationView {
    if (!_navigationView) {
        self._navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Utils screenWidth], [Utils headerHeight])];
        _navigationView.backgroundColor = [Utils headerColor];
        [_navigationView addSubview:self._titleLabel];
    }
    return _navigationView;
}

- (UISegmentedControl*)_filterSegmentControl {
    if (!_filterSegmentControl) {
        self._filterSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Русский", @"Pinyin"]];
        [_filterSegmentControl addTarget:self action:@selector(_loadData) forControlEvents:UIControlEventValueChanged];
        _filterSegmentControl.selectedSegmentIndex = VOC_RUSSIAN;
        _filterSegmentControl.frame = CGRectMake(0, self._navigationView.bottomBound + 1, [Utils screenWidth], [Utils widgetHeight]);
        
    }
    return _filterSegmentControl;
}

- (UISearchBar*)_searchBar {
    if (!_searchBar) {
        self._searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self._filterSegmentControl.bottomBound + 1, [Utils screenWidth], [Utils widgetHeight])];
        _searchBar.placeholder = @"Поиск...";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UITableView*)_wordTableView {
    if (!_wordTableView) {
        self._wordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self._searchBar.bottomBound, [Utils screenWidth], [Utils screenHeight] - self._searchBar.bottomBound - self.tabBarController.tabBar.bounds.size.height) style:UITableViewStylePlain];
        _wordTableView.dataSource = self;
        _wordTableView.delegate = self;
    }
    return _wordTableView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self._navigationView];
    [self.view addSubview:self._filterSegmentControl];
    [self.view addSubview:self._searchBar];
    [self.view addSubview:self._wordTableView];
    [self _loadData];
    UITapGestureRecognizer *tapper = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateEnded) {
            [self.view endEditing:YES];
        }
    }];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self._words.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    Word *word = [_words objectAtIndex:indexPath.row];
    NSString *mainWord = word.transcription;
    NSString *helperWord = word.translation;
    if (_filterSegmentControl.selectedSegmentIndex == VOC_RUSSIAN) {
        mainWord = word.translation;
        helperWord = word.transcription;
    }
    if (word.isFavorite) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", word.native, helperWord];
    cell.textLabel.text = mainWord;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Word *word = [_words objectAtIndex:indexPath.row];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[[PopupViewController alloc] initWithWord:word]];
    [popupController presentInViewController:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length]) {
        NSMutableArray *filtered = [NSMutableArray new];
        for (Word *word in [Word findAll]) {
            if ([[word.transcription stringByReplacingOccurrencesOfString:@" " withString:@""] rangeOfString:[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound || [word.translation rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound || [word.native rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filtered addObject:word];
            }
        }
        self._words = filtered;
        [self _filterWords];
        [self._wordTableView reloadData];
    } else {
        [searchBar.delegate searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self _loadData];
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
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
