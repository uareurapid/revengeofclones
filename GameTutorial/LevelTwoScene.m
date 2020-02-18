//
//  LevelTwoScene.m
//  RevengeOfTheClones
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "LevelTwoScene.h"

@implementation LevelTwoScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    return self;
}


-(void) setupStuff:(NSString *) backImage{
    [super setupStuff:backImage];
    self.flyingPipe.position = CGPointMake(180,160);
    [self.flyingPipe setScale:0.7];
    self.nextLevel = 3;
    self.birdVelocity = 10;
    
}


@end
