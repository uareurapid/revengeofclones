//
//  PipeNode.m
// 
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "PipeNode.h"




@implementation PipeNode

- (id)init
{
    if(self = [super init]){
        
        // TODO : use texture atlas
        SKTexture* pipeUp = [SKTexture textureWithImageNamed:@"pipe_up"];
        pipeUp.filteringMode = SKTextureFilteringNearest;
        
        SKTexture* pipeDown = [SKTexture textureWithImageNamed:@"pipe_down"];
        pipeDown.filteringMode = SKTextureFilteringNearest;

        
        self = [PipeNode spriteNodeWithTexture:pipeUp];
        
        self.moveUp = [SKAction animateWithTextures:@[pipeUp] timePerFrame:0.2];
        self.moveDown = [SKAction animateWithTextures:@[pipeDown] timePerFrame:0.2];
        
        //moving up by default
        [self setTexture:pipeUp];
        //self.flapForever = [SKAction repeatActionForever:self.flap];
        
    }
    
    return self;
    
}
@end
