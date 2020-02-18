//
//  MyScene.h
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PipeNode.h"
#import "BirdNode.h"
#import "ParticleEmitterNode.h"
#import "Score.h"
#import <AVFoundation/AVFoundation.h>

@interface MainScene : SKScene <SKPhysicsContactDelegate,AVAudioPlayerDelegate>
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger lifes;
@property (nonatomic) NSInteger groundPipes;
@property (strong,nonatomic) NSMutableArray *arrayOfParticles;
@property (assign,nonatomic) NSString *backgroundImage;

@property (strong,nonatomic) SKSpriteNode *flyingPipe;

-(void) setupStuff:(NSString *) backImage;
-(void) initMusicPlayer: (NSString *)filename;

@property (assign,nonatomic) NSString *backgroundMusicFile;

@property (nonatomic) NSInteger nextLevel;
@property BOOL premiumPurchased;
@property BOOL gamePaused;

//increases on each new level
@property (nonatomic) NSInteger birdVelocity;



@end
