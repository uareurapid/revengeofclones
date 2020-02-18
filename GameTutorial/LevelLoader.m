//
//  LevelLoader.m
//  RevengeOfTheClones
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "LevelLoader.h"
#import "iToast.h"
#import "LoadLevelHelper.h"
#import "SocialAPIHelper.h"
#import "ViewController.h"


@implementation LevelLoader

@synthesize nextLevel,easterEggCounter,previousScore;

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 1
        [self setupBackground];
        
        [self setupLevelsPurchase];
        //[self setupSocialButtons];
        [self setupGameCenterManager];
    }
    
    easterEggCounter = 0;
    previousScore = 0;
    return self;
}
-(void)setupBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background01"];
        background.position = CGPointMake(i*background.size.width, 0);
        background.anchorPoint = CGPointZero;
        [self addChild:background];
    }
    
    //name of the game!!!
    SKLabelNode *labelName = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    labelName.text = @"Revenge Of The Clones";
    labelName.fontSize = 32;
    labelName.fontColor = [SKColor orangeColor];
    labelName.position = CGPointMake(self.size.width/2, self.size.height/2 + 50 );
    labelName.name = @"game_name";
    [self addChild:labelName];
    
}
-(void) setupStuff {
    
    // 2
    NSString * message = nextLevel==1 ? [NSString stringWithFormat:@"Level %d",nextLevel]: [NSString stringWithFormat:@"Level %d Complete!",nextLevel-1];
    // 3
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy-Bold"];
    label.text = message;
    label.fontSize = 40;
    label.fontColor = [SKColor blackColor];
    label.position = CGPointMake(self.size.width/2, self.size.height/2+5);
    label.name = @"level";
    [self addChild:label];
    
    
    
    
    
    NSString * retrymessage;
    retrymessage = [NSString stringWithFormat: @"Play Level %d",nextLevel];
    SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy-Bold"];
    retryButton.text = retrymessage;
    retryButton.fontColor = [SKColor blackColor];
    retryButton.position = CGPointMake(self.size.width/2, (self.size.height/2) - 110);
    retryButton.name = @"retry";
    [retryButton setScale:.6];
    
    [self addChild:retryButton];
    
    
    
}



- (void)purchaseClicked {
  
    ViewController *root = (ViewController*)self.view.window.rootViewController;
    if(root!=nil && root.product!=nil) {
        root.notifierScene=self;
        [[RevengeClonesIAPHelper sharedInstance] buyProduct:root.product];
    }
    
}
- (void)restoreClicked {

    [[RevengeClonesIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)webClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://pcdreamsapps.wixsite.com/pcdreamsgames"]];
}

-(void)notifyPurchaseComplete: (BOOL) status {

    if(status) {
        
        ViewController *root = (ViewController*)self.view.window.rootViewController;
        if(root!=nil) {
           root.showAds = false; 
        }
        
        //OK
        //UPDATE UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadPurchaseUI];
        });
    }
}

//remove the locked nodes and add the unlocked
-(void) reloadPurchaseUI {
    
    /*
    NSLog(@"reload ui..");
    SKSpriteNode *levelTwoUnlocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_two_unlocked"];
    levelTwoUnlocked.name = @"level_two_unlocked";
    
    SKSpriteNode *levelThreeUnlocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_three_unlocked"];
    levelThreeUnlocked.name = @"level_three_unlocked";
    
    levelTwoUnlocked.position = CGPointMake(self.size.width * 1/2, (self.size.height/2)-40);
    levelThreeUnlocked.position = CGPointMake(self.size.width * 2/3, (self.size.height/2)-40);
    
    [self addChild:levelTwoUnlocked];
    [self addChild:levelThreeUnlocked];
    
    NSArray *nodes = self.children;//1
    for(SKNode * node in nodes){
        
        if([node.name isEqualToString: @"level_two_locked"] || [node.name isEqualToString: @"level_three_locked"]) {
            [node removeFromParent];
        }
        
    }*/
    
}

- (void) setupSocialButtons {
    
    SKSpriteNode *facebook = [SKSpriteNode spriteNodeWithImageNamed:@"SharetoFacebook"];
    facebook.name = @"facebook";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      [facebook setScale:0.7];
    else
      [facebook setScale:0.5];
    
    SKSpriteNode *twitter = [SKSpriteNode spriteNodeWithImageNamed:@"SharetoTwitter"];
    twitter.name = @"twitter";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [twitter setScale:0.7];
    else
        [twitter setScale:0.5];
    
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat aux;
    if(height>width) {
        aux = width;
        width = height;
        height = aux;
    }
    
    facebook.position = CGPointMake(self.size.width*1/4 , height-40);//self.size.height-
    twitter.position = CGPointMake(self.size.width*3/4 , height-40);//self.size.height-
    [self addChild: facebook];
    [self addChild:twitter];
    
}

//setup game center
- (void) setupGameCenterManager {

        
        SKSpriteNode *leaderBoard = [SKSpriteNode spriteNodeWithImageNamed:@"gamecenter"];
        leaderBoard.name = @"leaderboard";
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [leaderBoard setScale:0.1];
        else
            [leaderBoard setScale:0.05];
    
        leaderBoard.position = CGPointMake(self.size.width * 3/4+50, self.size.height*1/4 - 40);
        [self addChild: leaderBoard];
    
        if([GameKitHelper sharedGameKitHelper].enableGameCenter) {
            [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        }
}



//submit the score and show the leaderboard
- (void) submitScore {

    ViewController *root = (ViewController*)self.view.window.rootViewController;
    if(root!=nil) {
        NSLog(@"submit score %d", [Score bestScore]);
        [root submitScore: [Score bestScore] ];
    }
    

}

-(void) setupLevelsPurchase {
    
    //------------------------------------ GET THE SPRITES ------------------------------------------------------
    SKSpriteNode *levelOneUnlocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_one_unlocked"];
    levelOneUnlocked.name = @"level_one_unlocked";
    
    SKSpriteNode *levelTwoUnlocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_two_unlocked"];
    levelTwoUnlocked.name = @"level_two_unlocked";
    
    SKSpriteNode *levelThreeUnlocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_three_unlocked"];
    levelThreeUnlocked.name = @"level_three_unlocked";
    
    //
    //SKSpriteNode *levelTwoLocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_two_locked"];
    //levelTwoLocked.name = @"level_two_locked";
    
    //SKSpriteNode *levelThreeLocked = [SKSpriteNode spriteNodeWithImageNamed:@"level_three_locked"];
    //levelThreeLocked.name = @"level_three_locked";
    
    //-------------------------------------- SETUP POSITION ----------------------------------------------------
    
    levelOneUnlocked.position = CGPointMake(self.size.width * 1/3, (self.size.height/2)-40);
    levelTwoUnlocked.position = CGPointMake(self.size.width * 1/2, (self.size.height/2)-40);
    levelThreeUnlocked.position = CGPointMake(self.size.width * 2/3, (self.size.height/2)-40);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [levelOneUnlocked setScale:0.8];
        [levelTwoUnlocked setScale:0.8];
        [levelThreeUnlocked setScale:0.8];
    }
    else {
        [levelOneUnlocked setScale:0.6];
        [levelTwoUnlocked setScale:0.6];
        [levelThreeUnlocked setScale:0.6];
    }
    
    
    //Unlock 1 and 2 and 3
    [self addChild: levelOneUnlocked];
    [self addChild: levelTwoUnlocked];
    [self addChild: levelThreeUnlocked];
    
    //restore
    
    /*
    SKSpriteNode *restoreNode= [SKSpriteNode spriteNodeWithImageNamed:@"button_restore"];
    restoreNode.position = CGPointMake(self.size.width*1/4 -50, self.size.height*3/4 - 60);
    restoreNode.name = @"restore";
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [restoreNode setScale:0.8];
    else
        [restoreNode setScale:0.5];
    
    [self addChild:restoreNode];
    */
    
    //credits/web

    SKSpriteNode *creditsNode= [SKSpriteNode spriteNodeWithImageNamed:@"web"];
    creditsNode.position = CGPointMake(self.size.width*1/4-50, self.size.height*1/4 - 40);
    creditsNode.name = @"credits";
    [creditsNode setScale:0.8];
    [self addChild:creditsNode];
    
    /*
    SKSpriteNode *purchaseNode= [SKSpriteNode spriteNodeWithImageNamed:@"button_removeads"];
    purchaseNode.position = CGPointMake(self.size.width*3/4+50 , self.size.height*3/4 - 60);
    purchaseNode.name = @"purchase";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [purchaseNode setScale:0.8];
    else
        [purchaseNode setScale:0.5];
    [self addChild:purchaseNode];
    
    */
    
    //Changed on 11/07/2014 (Unlocked levels 1 and 2)
    //----------------------------------------CHECK PURCHASED ITEMS ---------------------------------------------
    //CHECK IF IF WE HAVE PURCHASED THE ITEM
    /*if([[RevengeClonesIAPHelper sharedInstance] productPurchased:PRODUCT_REVENGE_CLONES_PREMIUM]) {
        //if so, we unlock the levels, otherwise we block them
        //unlock the level 3
        ViewController *root = (ViewController*)self.view.window.rootViewController;
        //if(root!=nil) {
        //    root h
        //}
    }*/
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    /*if([node.name rangeOfString:@"facebook"].location!=NSNotFound
       || [node.name rangeOfString:@"twitter"].location!=NSNotFound) {
        //share to facebook
        if([node.name isEqualToString:@"facebook"]) {
            
            [[SocialAPIHelper sharedInstance] sendToFacebook: [NSString stringWithFormat: @"My Revenge Of The Clones Score: %d",[Score bestScore]]
                                                    fromView:self.view.window.rootViewController];
        }
        else if([node.name isEqualToString:@"twitter"]) {
            [[SocialAPIHelper sharedInstance ] sendToTwitter: [NSString stringWithFormat: @"My Revenge Of The Clones Score: %d",[Score bestScore]]
                                                    fromView:self.view.window.rootViewController];
        }
    }*/
    if([node.name isEqualToString:@"leaderboard"]) {
        [self submitScore];
    }
    else if([node.name isEqualToString:@"level_one_unlocked"]) {
        [self loadLevel:1];
    }
    else if([node.name isEqualToString:@"level_two_unlocked"]) {
        [self loadLevel:2];
    }
    else if([node.name isEqualToString:@"level_three_unlocked"]) {
        [self loadLevel:3];
    }
    else if ([node.name isEqualToString:@"retry"]) {
        [self loadLevel: nextLevel==1 ? 1 : nextLevel];
        
    }
    //else if ([node.name isEqualToString:@"restore"]) {
    //    [self restoreClicked];
        
    //}
    else if ([node.name isEqualToString:@"credits"]) {
        [self webClicked];
        
    }
    //else if([node.name isEqualToString:@"purchase"]) {
    //    [[[[iToast makeText:@"Upgrading!..."]
    //       setGravity:iToastGravityBottom] setDuration:1000] show];
    //    [self purchaseClicked];
    //}
    //for the Easter Egg
    else if ([node.name isEqualToString:@"level"]) {
        easterEggCounter+=1;
        if(easterEggCounter>20) {
            //UNLOCK PREMIUM
            [[RevengeClonesIAPHelper sharedInstance] provideContentForProductIdentifier:PRODUCT_REVENGE_CLONES_PREMIUM];
            [self notifyPurchaseComplete:true];
            [[[[iToast makeText:@"Congratulations! You found the Egg!"]
               setGravity:iToastGravityBottom] setDuration:1000] show];
        }
        
    }
    
    
    
}



-(void) loadLevel:(int) number {
    
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene *level;
    
    switch (number) {
        case 1:
            level = [MainScene sceneWithSize:self.view.bounds.size];
            [((MainScene*)level) setupStuff:@"background01"];
            [((MainScene*)level) initMusicPlayer: @"Monkeys Spinning Monkeys.mp3"];
            
            break;
        case 2:
            level = [LevelTwoScene sceneWithSize:self.view.bounds.size];
            //preserve the previous score
            if(previousScore>0) {
                ((LevelTwoScene*)level).score = previousScore;
            }
            [((LevelTwoScene*)level) setupStuff:@"backmy"];
            [((LevelTwoScene*)level) initMusicPlayer:@"Run Amok.mp3"];
            
            break;
        case 3:
            level = [LevelThreeScene sceneWithSize:self.view.bounds.size];
            //preserve the previous score
            if(previousScore>0) {
                ((LevelTwoScene*)level).score = previousScore;
            }
            [((LevelThreeScene*)level) setupStuff:@"sky"];
            [((LevelThreeScene*)level) initMusicPlayer:@"The Builder.mp3"];
            
            break;
        default:
            level = [MainScene sceneWithSize:self.view.bounds.size];
            [((MainScene*)level) setupStuff:@"background01"];
            [((MainScene*)level) initMusicPlayer: @"Monkeys Spinning Monkeys.mp3"];
            break;
    }

    level.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:level transition: reveal];
}



@end
