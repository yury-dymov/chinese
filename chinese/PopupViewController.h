//
//  PopupViewController.h
//  chinese
//
//  Created by Dymov, Yuri on 10/15/15.
//  Copyright © 2015 Dymov, Yuri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"

@interface PopupViewController : UIViewController

- (id)initWithWord:(Word*)aWord;

@property (nonatomic, strong) Word *word;

@end
