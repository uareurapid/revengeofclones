//
//  LoadLevelHelper.h
//  revengeofclones
//
//  Created by Paulo Cristo on 10/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "LevelLoader.h"
#import "MainScene.h"
#import "LevelTwoScene.h"
#import "LevelThreeScene.h"

@interface LoadLevelHelper : NSObject

+ (LoadLevelHelper *)sharedInstance; 

-(void) loadOrPurchaseLevel:(LevelLoader *) levelLoader nodeClicked:(SKNode *) node;

@end
