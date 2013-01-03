//
//  KSMasterViewController.h
//  KSGithubStatusAPI iOS
//
//  Created by Keith Smiley on 1/3/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDetailViewController;

@interface KSMasterViewController : UITableViewController

@property (strong, nonatomic) KSDetailViewController *detailViewController;

@end
