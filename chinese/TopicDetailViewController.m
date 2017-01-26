//
//  TopicDetailViewController.m
//  chinese
//
//  Created by Dymov, Yuri on 10/16/15.
//  Copyright © 2015 Dymov, Yuri. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "UIKit+Offset.h"
#import "Word.h"
#import "PopupViewController.h"
#import <STPopup.h>

@interface TopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *_words;
@property (nonatomic, strong) UITableView *_wordTableView;
@property (nonatomic, strong) UISearchBar *_searchBar;

@end


@implementation TopicDetailViewController
@synthesize topic;
@synthesize _words;
@synthesize _wordTableView;
@synthesize _searchBar;

- (id)initWithTopic:(Topic *)aTopic {
    self = [super init];
    if (self) {
        self.topic = aTopic;
        [[NSNotificationCenter defaultCenter] addObserverForName:@"syncDone" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self _reloadData];
        }];
    }
    return self;
}


- (void)setTopic:(Topic *)atopic {
    if (topic != atopic) {
        topic = atopic;
    }
    self.title = topic.title;
    [self _reloadData];
}

- (void)_reloadData {
    self._words = [topic.words sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [[obj1 translation] compare:[obj2 translation] options:NSCaseInsensitiveSearch];
    }];
    [_wordTableView reloadData];
}

- (UITableView*)_wordTableView {
    if (!_wordTableView) {
        self._wordTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _wordTableView.delegate = self;
        _wordTableView.dataSource = self;
    }
    return _wordTableView;
}

- (UISearchBar*)_searchBar {
    if (!_searchBar) {
        self._searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.placeholder = @"Поиск...";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_wordTableView.superview) {
        [self.view addSubview:self._searchBar];
        [self.view addSubview:self._wordTableView];
    }
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    _wordTableView.frame = CGRectMake(0, _searchBar.bottomBound, self.view.bounds.size.width, self.view.bounds.size.height - 44 - _searchBar.bottomBound);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _words.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndetifier = @"wordCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndetifier];
    }
    Word *word = [_words objectAtIndex:indexPath.row];
    NSString *mainWord = word.transcription;
    NSString *helperWord = word.translation;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length]) {
        NSMutableArray *filtered = [NSMutableArray new];
        for (Word *word in topic.words) {
            if ([[word.transcription stringByReplacingOccurrencesOfString:@" " withString:@""] rangeOfString:[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound || [word.translation rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound || [word.native rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filtered addObject:word];
            }
        }
        self._words = filtered;
        [_wordTableView reloadData];
    } else {
        [searchBar.delegate searchBarCancelButtonClicked:searchBar];
        [self _reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self _reloadData];
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
