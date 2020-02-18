//
//  LevelTwoScene.m
//  RevengeOfTheClones
//
//  Created by Paulo Cristo on 09/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "LevelThreeScene.h"

@implementation LevelThreeScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    return self;
}


-(void) setupStuff:(NSString *) backImage{
    [super setupStuff:backImage];
    super.flyingPipe.position = CGPointMake(200,160);
    [self.flyingPipe setScale:0.6];
    self.nextLevel = 1;
    //faster than level 2
    self.birdVelocity = 20;

    
}


@end
