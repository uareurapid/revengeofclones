//
//  LevelLoader.h
//  RevengeOfTheClones
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <StoreKit/StoreKit.h>
#import <GameKit/GameKit.h>
#import "RevengeClonesIAPHelper.h"
#import "GameKitHelper.h"



#define REVENGE_OF_CLONES_LEADERBOARD_ID @"revengeofclones.leaderboard"

@interface LevelLoader : SKScene

@property (nonatomic) NSInteger nextLevel;
@property (nonatomic) NSInteger easterEggCounter;

//GAME CENTER STUFF
@property (strong, nonatomic) SKProduct *product;

@property NSInteger previousScore;

- (IBAction) submitScore;

-(void) setupSocialButtons;
-(void) setupLevelsPurchase;
-(void) loadLevel:(int) number;
- (void)purchaseClicked;
-(void)notifyPurchaseComplete: (BOOL) status;

-(void) setupStuff;

@end
