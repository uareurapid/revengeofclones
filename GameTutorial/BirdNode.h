//
//  BirdNode.h
//
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BirdNode : SKSpriteNode

- (id) initWithSpriteSheetNamed: (NSString *) spriteSheet withRect:(NSMutableArray *) cgRectArray;
@property (strong,nonatomic) NSMutableArray *animatingFrames;
@property (strong,nonatomic) SKAction * flap;
@property (strong,nonatomic) SKAction * flapForever;
@property BOOL isBurning;

@end
