//
//  PipeNode.h
//  
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PipeNode : SKSpriteNode

@property (strong,nonatomic) SKAction * moveUp;
@property (strong,nonatomic) SKAction * moveDown;
@property BOOL goingUp;

@end
