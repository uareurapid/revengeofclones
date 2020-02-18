//
//  ViewController.h
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <StoreKit/StoreKit.h>
#import "LevelLoader.h"
#import "LevelLoader.h"
#import "GameKitHelper.h"
#import "PCPopupViewController.h"

@import GoogleMobileAds;

#define PROMO_SHOW_COUNTER @"promo_show_counter"

@interface ViewController : UIViewController <SKProductsRequestDelegate,GADBannerViewDelegate,GADInterstitialDelegate,GameKitHelperDelegate,GKGameCenterControllerDelegate>


@property BOOL timeToShowPromoPopup;
@property BOOL premiumPurchased;
@property BOOL showAds;
@property (strong,nonatomic) LevelLoader *notifierScene;
@property (strong,nonatomic) SKProduct *product;
@property (strong, nonatomic) GADBannerView *bannerView;
// Declare one as an instance variable
@property (strong, nonatomic) GADInterstitial *interstitial;
@property (strong,nonatomic) SKView * skView;
//to open flappy

@property (strong, nonatomic) PCPopupViewController  *popupView;

-(void) setupInterstitial;
-(void) updateBannerView;
-(void) showInterstitial;
@end
