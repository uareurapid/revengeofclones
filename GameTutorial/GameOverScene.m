//
//  GameOverScene.m
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "GameOverScene.h"
#import "MainScene.h"
#import "Constants.h"
#import "SocialAPIHelper.h"
#import "RevengeClonesIAPHelper.h"
#import "LoadLevelHelper.h"
#import "iToast.h"
#import "ViewController.h"


@implementation GameOverScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 1
        //self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
     
    }
    return self;
}

/**
 *setup stuff
 */
-(void)setupStuff {
    // 2
    NSString * message;
    message = @"Game Over!";
    // 3
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy-Bold"];
    label.text = message;
    label.fontSize = 40;
    label.fontColor = [SKColor blackColor];
    label.position = CGPointMake(self.size.width/2, self.size.height/2+5);
    [self addChild:label];
    
    
    NSString * retrymessage;
    retrymessage = @"Replay Game";
    SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy-Bold"];
    retryButton.text = retrymessage;
    retryButton.fontColor = [SKColor blackColor];
    retryButton.position = CGPointMake(self.size.width/2, 60);
    retryButton.name = @"retry";
    [retryButton setScale:0.8];
    
    [self addChild:retryButton];

    
  
}





- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    
    if([node.name rangeOfString:@"facebook"].location!=NSNotFound
       || [node.name rangeOfString:@"twitter"].location!=NSNotFound) {
        //share to facebook
        if([node.name isEqualToString:@"facebook"]) {
            
            [[SocialAPIHelper sharedInstance] sendToFacebook:[NSString stringWithFormat: @"My Revenge Of The Clones Score: %ld",(long)[Score bestScore]]
                                                    fromView:self.view.window.rootViewController];
        }
        else if([node.name isEqualToString:@"twitter"]) {
            [[SocialAPIHelper sharedInstance ] sendToTwitter:[NSString stringWithFormat: @"My Revenge Of The Clones Score: %ld",(long)[Score bestScore]]
                                                    fromView:self.view.window.rootViewController];
        }
    }
    else if([node.name isEqualToString:@"leaderboard"]) {
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
        [self loadLevel: ((self.nextLevel==1) ? 1 : self.nextLevel) ];
        
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
            [((LevelTwoScene*)level) setupStuff:@"backmy"];
            [((LevelTwoScene*)level) initMusicPlayer:@"Run Amok.mp3"];
            break;
        case 3:
            level = [LevelThreeScene sceneWithSize:self.view.bounds.size];
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

-(void) didMoveToView:(SKView *)view{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    if([rootViewController isKindOfClass:ViewController.class]) {
        ViewController *root = (ViewController *)rootViewController;
        [root showInterstitial];
    }
    
}

@end
