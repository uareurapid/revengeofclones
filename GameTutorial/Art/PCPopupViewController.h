//
//  PCPopupViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 26/03/14.
//  Copyright (c) 2014 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PCPopupViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewRight;
- (IBAction)closeClicked:(id)sender;


@end
