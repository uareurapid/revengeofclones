//
//  BirdNode.m
//  
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "BirdNode.h"

@implementation BirdNode

@synthesize animatingFrames,flap,flapForever,isBurning;

- (id) initWithSpriteSheetNamed: (NSString *) spriteSheet withRect:(NSMutableArray *) cgRectArray{
    
    if(self = [super init]) {
        // @param numberOfSprites - the number of sprite images to the left
        // @param scene - I add my sprite to a map node. Change it to a SKScene
        // if [self addChild:] is used.
        
        animatingFrames = [[NSMutableArray alloc] init];
        
        SKTexture  *ssTexture = [SKTexture textureWithImageNamed:spriteSheet];
        // Makes the sprite (ssTexture) stay pixelated:
        ssTexture.filteringMode = SKTextureFilteringNearest;
        
        
        int numImages = (int)cgRectArray.count;
        
        
        for(int i=0; i < numImages; i++) {
            
            NSString *obj =  (NSString*)[cgRectArray objectAtIndex:i];
            CGRect rect = CGRectFromString( obj );
            
            float sx = rect.origin.x;
            float sy = rect.origin.y;
            float sWidth = rect.size.width;
            float sHeight = rect.size.height;
            
            //NSLog(@"x: %f  y: %f  width: %f  height: %f textute width: %f texture height: %f",sx,sy,sWidth,sHeight,ssTexture.size.width,ssTexture.size.height);
            
            // IMPORTANT: textureWithRect: uses 1 as 100% of the sprite.
            // This is why division from the original sprite is necessary.
            // Also why sx is incremented by a fraction.
            
            //for (int i = 0; i < numberOfSprites; i++) {
            //NSLog(@"translating to %f, %f, %f, %f",sx/ssTexture.size.width, sy/ssTexture.size.height, sWidth/ssTexture.size.width, sHeight/ssTexture.size.height);
            CGRect cutter = CGRectMake(sx/ssTexture.size.width, sy/ssTexture.size.height, sWidth/ssTexture.size.width, sHeight/ssTexture.size.height);
            //CGRect cutter = CGRectMake(sx, sy,sWidth,sHeight);
            SKTexture *temp = [SKTexture textureWithRect:cutter inTexture:ssTexture];
            
            
            [animatingFrames addObject:temp];
            
            
        }
        
        
        SKTexture *rootTexture = [animatingFrames objectAtIndex:0];
        SKTexture *texture2 = [animatingFrames objectAtIndex:1];
        SKTexture *texture3 = [animatingFrames objectAtIndex:2];

        self = [BirdNode spriteNodeWithTexture:rootTexture];
        self.flap = [SKAction animateWithTextures:@[rootTexture,texture2,texture3] timePerFrame:0.2];
        self.flapForever = [SKAction repeatActionForever:self.flap];
        
        [self setTexture:rootTexture];
        [self runAction:self.flapForever withKey:@"flapForever"];
        
        self.isBurning = false;
        //[scene addChild:self];
    }
    
    
    return self;
}

@end
