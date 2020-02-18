//
//  RotatableViewController.h
//  RevengeOfClones
//
//  Created by Paulo Cristo on 19/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface RotatableViewController : UIViewController<SKStoreProductViewControllerDelegate>
//properties
@property (assign,nonatomic) NSString *appStoreID;
@property SKStoreProductViewController *storeController;
@property BOOL storeOpen;
//methods
- (void)canRotate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andAppID:(NSString *) appID;
@end
