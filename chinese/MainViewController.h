//
//  MainViewController.h
//  Karten
//
//  Created by Dymov, Yuri on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfPagedScrollView.h"

@class SettingViewController;

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, InfPagedScrollViewDataSource>

@end
