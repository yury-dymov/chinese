//
//  TopicViewController.m
//  chinese
//
//  Created by Dymov, Yuri on 10/16/15.
//  Copyright © 2015 Dymov, Yuri. All rights reserved.
//

#import "TopicViewController.h"
#import "Topic.h"
#import "TopicDetailViewController.h"
#import "Utils.h"

@interface TopicViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *_topicTableView;
@property (nonatomic, strong) NSArray *_data;

@end

@implementation TopicViewController
@synthesize _topicTableView;
@synthesize _data;

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"syncDone" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self _reloadData];
        }];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Темы" image:[UIImage imageNamed:@"topics"] tag:2];
    }
    return self;
}

- (void)_reloadData {
    self._data = [Topic findAll];
    [_topicTableView reloadData];
}

- (UITableView*)_topicTableView {
    if (!_topicTableView) {
        self._topicTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _topicTableView.backgroundColor = [UIColor clearColor];
        _topicTableView.delegate = self;
        _topicTableView.dataSource = self;
    }
    return _topicTableView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_topicTableView.superview) {
        [self.view addSubview:self._topicTableView];
        [self _reloadData];
    }
    _topicTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Темы";
    self.navigationController.navigationBar.barTintColor = [Utils headerColor];
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self._data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndetifier = @"topicCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }
    Topic *topic = [_data objectAtIndex:indexPath.row];
    cell.textLabel.text = topic.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = [_data objectAtIndex:indexPath.row];
    TopicDetailViewController *tdvc = [[TopicDetailViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:tdvc animated:YES];
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
