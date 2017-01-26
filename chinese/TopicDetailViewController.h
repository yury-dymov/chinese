//
//  TopicDetailViewController.h
//  chinese
//
//  Created by Dymov, Yuri on 10/16/15.
//  Copyright © 2015 Dymov, Yuri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"

@interface TopicDetailViewController : UIViewController

- (id)initWithTopic:(Topic*)aTopic;

@property (nonatomic, strong) Topic *topic;

@end
