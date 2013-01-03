//
//  KSDetailViewController.h
//  KSGithubStatusAPI iOS
//
//  Created by Keith Smiley on 1/3/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
