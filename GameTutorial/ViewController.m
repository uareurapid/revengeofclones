//
//  ViewController.m
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "ViewController.h"
#import "MainScene.h"
#import "Constants.h"
#import "LevelLoader.h"
#import "RevengeClonesIAPHelper.h"
#import "iToast.h"
#import "RotatableViewController.h"


@implementation ViewController  {
    
    
    LevelLoader *scene;
}
@synthesize product,premiumPurchased,notifierScene;
@synthesize showAds,bannerView,interstitial,skView,timeToShowPromoPopup,popupView;


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.title=@"Revenge Of The Clones";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    if ([SKPaymentQueue canMakePayments]) {
      [self reloadProducts];
    }
    
    [self setupGameCenter];
    
    
    skView = (SKView *)self.view;
    
 
    
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        scene = [LevelLoader sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.nextLevel = 1;
        [scene setupStuff];
        
        // Present the scene.
        [skView presentScene:scene];
    }
}



-(void)setupGameCenter {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    if(![GameKitHelper sharedGameKitHelper].enableGameCenter){
      [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    }
 
    
    
    
    
}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
    [self presentViewController:
     gameKitHelper.authenticationViewController
                                         animated:YES
                                       completion:nil];
}



-(BOOL)prefersStatusBarHidden{
    return YES;
}

//get the InAPP PRODUCTS
- (void)reloadProducts {
    
    [[RevengeClonesIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success && products.count>0) {
            self.product = [products objectAtIndex:0];
            NSLog(@"Saved product %@",self.product.localizedDescription);
        }
    }];
    
}

//get the notification when a product is purchased
- (void)productPurchased:(NSNotification *)notification {
    NSLog(@"completed purchase");
    self.premiumPurchased = true;
    [notifierScene notifyPurchaseComplete:true];
    
}

-(void)viewWillAppear:(BOOL)animated {
    /*if(timeToShowPromoPopup ) {
        [self setupPromoViewTouch];
        
        [NSTimer scheduledTimerWithTimeInterval:5.0  target:self
                                                          selector:@selector(showPopupView:)
                                                          userInfo:nil
                                                           repeats:NO];
    }*
}

-(IBAction)showPopupView:(id)sender {
    
    
   /* popupView = [[PCPopupViewController alloc] initWithNibName:@"PCPopupViewController" bundle:nil];
    popupView.view.alpha=0.9;
    
    [self setupPromoViewTouch];
    
    [self.view addSubview:popupView.view];*/
    
    
}



//setup touch on promo image
-(void) setupPromoViewTouch {
    
    popupView.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPromoViewWithGesture:)];
    [popupView.imageView addGestureRecognizer:tapGesture];
    
    popupView.imageViewRight.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureSecond =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSecondPromoViewWithGesture:)];
    [popupView.imageViewRight addGestureRecognizer:tapGestureSecond];
    
}
//open flapi
- (void)didTapPromoViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [popupView.view removeFromSuperview];
    RotatableViewController *controller =[[RotatableViewController alloc] initWithNibName:@"RotatableViewController" bundle:nil andAppID:@"837165900"];
    [self presentViewController:controller animated:YES completion:^{
        timeToShowPromoPopup = false;}];//next time the view appear we do not show it
    
}
//open easymessage
- (void)didTapSecondPromoViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [popupView.view removeFromSuperview];
    RotatableViewController *controller = [[RotatableViewController alloc] initWithNibName:@"RotatableViewController" bundle:nil andAppID:@"668776671"];
    [self presentViewController:controller animated:YES completion:^{
        timeToShowPromoPopup = false;}];//next time the view appear we do not show it
    
}




- (void)viewDidLoad {
    
    self.showAds = [[RevengeClonesIAPHelper sharedInstance] productPurchased:PRODUCT_REVENGE_CLONES_PREMIUM];
    //NSLog(@"Is premium pack? %@",showAds==true?@"false":@"true");
    
    if(showAds) {
        //[self createAdBannerView];
        [self setupInterstitial];
        //[NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
        //                                                 selector: @selector(callBannerCheck:) userInfo: nil repeats: YES];
    }
    
    //check popup times counter
    NSInteger times;
    if (![[NSUserDefaults standardUserDefaults] valueForKey:PROMO_SHOW_COUNTER]) {
        times = 0;
    }
    else {
        times = [[NSUserDefaults standardUserDefaults]  integerForKey:PROMO_SHOW_COUNTER ];
    }
    
    if(times==0) {
        timeToShowPromoPopup = true;//first time we open this
        times = times +1;
        //self.showAds = true;
    }
    else {
        timeToShowPromoPopup = false;
       // self.showAds = false;
        
        if(times == 3) {
            //if we loaded 3 times than reset the counter, to show next time
            times = 0;
        }
        //otherwise just increase the counter
        else {
            times = times +1;
        }
    }
    
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:times forKey:PROMO_SHOW_COUNTER];
    
    [super viewDidLoad];
}


//setup the interstitial
-(void) setupInterstitial{
    
    self.interstitial = [[GADInterstitial alloc]
                         initWithAdUnitID:@"ca-app-pub-9531252796858598/6446965662"];
    
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
    
}
#pragma mark GADInterstitialDelegate
//received the interstitial add
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"Received ad successfully");
    [self showInterstitial];
    //[interstitial presentFromRootViewController:self];
}

-(void) showInterstitial {
    
    if(self.interstitial != nil) {
        if(self.interstitial.isReady) {
            [interstitial presentFromRootViewController:self];
        }
    } else {
        [self setupInterstitial];
    }
}
//failed to receive the interstitial add
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    // Remove the imageView_ once the interstitial is dismissed.
}

/**
 *Create the banner view
 */
- (void) createAdBannerView {
    
    NSLog(@"create banner");
    //******* BANNER **************
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    
    GADAdSize sizeOfBanner = kGADAdSizeBanner;
    // Initialize the banner at the bottom of the screen.
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize(sizeOfBanner).height);
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];//origin:origin
    
    // Specify the ad unit ID.
    bannerView.adUnitID = @"ca-app-pub-9531252796858598/9189476861";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];

    GADRequest *request = [GADRequest request];

    // Initiate a generic request to load it with an ad.
    [bannerView loadRequest:request];
    
}

#pragma mark - ADBannerViewDelegate


- (void)adViewDidReceiveAd:(GADBannerView *)bannerViewParam {
    [UIView beginAnimations:@"BannerSlide" context:nil];
    bannerViewParam.frame = CGRectMake(0.0,
                                       self.view.frame.size.height -
                                       bannerViewParam.frame.size.height,
                                       bannerViewParam.frame.size.width,
                                       bannerViewParam.frame.size.height);
    [UIView commitAnimations];
    bannerView.hidden = false;
    NSLog(@"received ad");
    
}

- (void)adView:(GADBannerView *)bannerViewParam
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}


- (void)dealloc {
    // ... your other -dealloc code ...
    self.bannerView = nil;
    self.interstitial = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) callBannerCheck:(NSTimer*) t
{
    if(self.bannerView!=nil) {
        [self updateBannerView];
    }
}

-(void) updateBannerView {
    
    
    if(self.showAds==false){
        [self.bannerView setHidden: true];
    }
    else {
        [self.bannerView setHidden: !self.bannerView.isHidden];
    }
}

#pragma mark game center


-(void) submitScore:(NSInteger ) score {
    
    //just show the leaderboard
    if(score==0 && [GKLocalPlayer localPlayer].isAuthenticated) {
        [self showLeaderboard];
    }
   
    else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            GKScore* thescore = [[GKScore alloc] initWithLeaderboardIdentifier:REVENGE_OF_CLONES_LEADERBOARD_ID];
            thescore.value = (long)score;
            NSArray  *array = [[NSArray alloc] initWithObjects:thescore,nil];
            [GKScore reportScores:array withCompletionHandler:^(NSError *error) {
                if (error) {
                    // handle error
                    NSLog(@"Unable to submit score: %@",error.description);
                }
                [self showLeaderboard];
                
            }];
        }
    else {
            [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        
    }
   
}
//our protocol method
- (void) showLeaderboard {
    [self presentLeaderboards];
}

- (void) presentLeaderboards {
  
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.gameCenterDelegate = self;
    [self presentViewController:gameCenterController animated:YES completion:nil];
}

- (void) gameCenterViewControllerDidFinish:(GKGameCenterViewController*) gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
