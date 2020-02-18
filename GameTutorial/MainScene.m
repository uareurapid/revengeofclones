//
//  MyScene.m
//  GameTutorial
//
//  Created by Paulo Cristo on 10/26/13.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "MainScene.h"
#import "GameOverScene.h"
#import "Constants.h"
#import "iToast.h"
#import "ViewController.h"

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180


#define BLUE_BIRD_CGRECT_1 CGRectMake(1024-230-34, 342, 34, 24);
#define BLUE_BIRD_CGRECT_2 CGRectMake(1024-230-34, 290, 34, 24);
#define BLUE_BIRD_CGRECT_3 CGRectMake(1024-174-34, 18, 34, 24);

#define RED_BIRD_CGRECT_1 CGRectMake(1024-230-34, 238, 34, 24);
#define RED_BIRD_CGRECT_2 CGRectMake(1024-230-34, 186, 34, 24);
#define RED_BIRD_CGRECT_3 CGRectMake(1024-230-34, 134, 34, 24);

#define YELLOW_BIRD_CGRECT_1 CGRectMake(1024-6-34, 18, 34, 24);
#define YELLOW_BIRD_CGRECT_2 CGRectMake(1024-62-34, 18, 34, 24);
#define YELLOW_BIRD_CGRECT_3 CGRectMake(1024-118-34, 18, 34, 24);


static const uint32_t flyingPipeCategory =  0x1 << 0;
static const uint32_t birdCategory =  0x1 << 1;
static const uint32_t bombCategory =  0x1 << 2;
static const uint32_t groundPipeCategory =  0x1 << 3;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 130.0;//was 160
static const int SCORE_SPEED_INCREASE_FACTOR = 15;

static const int NUM_LIFES = 3;



#define BOUNCE_FORCE_FACTOR 10

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}



@implementation MainScene{

    //pipe stuff
    
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    SKAction *actionUpdateMoveUpSprite;
    SKAction *actionUpdateMoveDownSprite;
    
    SKAction *actionRotateSwingBack;
    SKAction *actionRotateSwingFront;
    
    SKAction *actionMoveFlappyLeft;
    SKAction *actionMoveFlappyRight;
    
    AVAudioPlayer * _backgroundMusicPlayer;
    
    SKAction *pulseRed;
    SKAction *changeToDarker;

    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastBirdAdded;
    SKLabelNode * scoreLabel;
    
    SKSpriteNode *pauseButton;
    SKAction *actionShowPauseButton;
    SKAction *actionShowPlayButton;
    BOOL goingUp;
    

}

@synthesize nextLevel,premiumPurchased;
@synthesize arrayOfParticles,backgroundImage,flyingPipe,gamePaused,backgroundMusicFile,birdVelocity;



-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        premiumPurchased = [[RevengeClonesIAPHelper sharedInstance] productPurchased:PRODUCT_REVENGE_CLONES_PREMIUM];
        self.score = 0;
    
    }
    return self;
}

-(void) initMusicPlayer: (NSString *)filename {
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _backgroundMusicPlayer.numberOfLoops = -1; //inifite loop
    _backgroundMusicPlayer.volume = 0.5;
    _backgroundMusicPlayer.delegate = self;
}

-(void) didMoveToView:(SKView *)view {
    
    [self startMusic];
}


-(void) startMusic {
    
    //Playing sound action:
    
    
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
    
}

-(void) stopMusic {
    if([_backgroundMusicPlayer isPlaying]) {
       [_backgroundMusicPlayer stop];
    }
    
    
}

-(void) decreaseLife {
    self.lifes = self.lifes -1;
    self.groundPipes = self.groundPipes -1;

    if(self.lifes<0) {
        self.lifes = 0;
    }
    if(self.groundPipes<0) {
        self.groundPipes = 0;
        
    }
    
    [flyingPipe runAction: pulseRed];
    
}

-(ParticleEmitterNode *) addParticle: (NSString *) particleName andInterval: (float) timeToLive {
    
    ParticleEmitterNode *myParticle = [[ParticleEmitterNode alloc] initWithName:particleName andTimeToLive:timeToLive andCreationDate:_lastUpdateTime];
    
    [arrayOfParticles addObject:myParticle];

    return myParticle;
}



-(void)addFlyingPipe
{
        //flyingPipe = [PipeNode new];
    
    // TODO : use texture atlas
        SKTexture* pipeUp = [SKTexture textureWithImageNamed:@"pipe_up"];
        pipeUp.filteringMode = SKTextureFilteringNearest;
    
        SKTexture* pipeDown = [SKTexture textureWithImageNamed:@"pipe_down"];
        pipeDown.filteringMode = SKTextureFilteringNearest;
    
        flyingPipe = [SKSpriteNode spriteNodeWithTexture:pipeUp];
        if(premiumPurchased) {
            [flyingPipe setScale:1.1];
        }
        else {
            [flyingPipe setScale:0.8];
        }
    
        //ship.zRotation = - M_PI / 2;
    
        //Adding SpriteKit physicsBody for collision detection
        flyingPipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:flyingPipe.size];
        flyingPipe.physicsBody.categoryBitMask = flyingPipeCategory;
        flyingPipe.physicsBody.dynamic = YES;
        flyingPipe.physicsBody.contactTestBitMask = birdCategory | bombCategory;
        flyingPipe.physicsBody.collisionBitMask = birdCategory | bombCategory;//0;
        flyingPipe.physicsBody.usesPreciseCollisionDetection = YES;
        [flyingPipe.physicsBody setMass:100];//must be bigger than the bom mass
        flyingPipe.name = @"pipe";
    
        
        //put it in the middle of screen in height
    
        //pipeWings.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeWings.size];

    
        actionUpdateMoveUpSprite = [SKAction animateWithTextures:@[pipeUp] timePerFrame:0.2];
        actionMoveUp = [SKAction moveByX:0 y:30 duration:.2];
    
        actionUpdateMoveDownSprite = [SKAction animateWithTextures:@[pipeDown] timePerFrame:0.2];
        actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    
        actionRotateSwingBack = [SKAction rotateByAngle:SK_DEGREES_TO_RADIANS(20) duration:0.1];
        actionRotateSwingFront = [SKAction rotateByAngle:SK_DEGREES_TO_RADIANS(-20) duration:0.1];

        [self addChild:flyingPipe];
    
        pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                                              [SKAction waitForDuration:0.1],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
    
       //action sequence to change pipe color, to a burned gray
       changeToDarker = [SKAction sequence:@[
                                    [SKAction colorizeWithColor:[SKColor blackColor] colorBlendFactor:1.0 duration:0.15],
                                    [SKAction waitForDuration:0.5],
                                    [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
    
    
}



-(void)addGroundPipe
{
    //flyingPipe = [PipeNode new];
    
    // TODO : use texture atlas
    SKTexture* pipeUp = [SKTexture textureWithImageNamed:@"pipe"];
    pipeUp.filteringMode = SKTextureFilteringNearest;
    
    
    SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithTexture:pipeUp];
    //[pipe setScale:0.8];
    //ship.zRotation = - M_PI / 2;
    
    //Adding SpriteKit physicsBody for collision detection
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeUp.size];
    pipe.physicsBody.categoryBitMask = groundPipeCategory;
    pipe.physicsBody.dynamic = YES;
    [pipe.physicsBody setMass:120];
    pipe.physicsBody.contactTestBitMask = bombCategory | birdCategory;
    pipe.physicsBody.collisionBitMask = bombCategory | birdCategory;//3;
    pipe.physicsBody.usesPreciseCollisionDetection = YES;
    pipe.name = @"ground_pipe";
    
    //put it in the middle of screen in height
    pipe.position = CGPointMake(20,20);
    
    
    [self addChild:pipe];
    
    SKSpriteNode *pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeUp];
    //[pipe setScale:0.8];
    //ship.zRotation = - M_PI / 2;
    
    //Adding SpriteKit physicsBody for collision detection
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeUp.size];
    pipe2.physicsBody.categoryBitMask = groundPipeCategory;
    pipe2.physicsBody.dynamic = YES;
    [pipe2.physicsBody setMass:120];
    pipe2.physicsBody.contactTestBitMask = bombCategory | birdCategory;
    pipe2.physicsBody.collisionBitMask = bombCategory | birdCategory;//3;
    pipe2.physicsBody.usesPreciseCollisionDetection = YES;
    pipe2.name = @"ground_pipe";
    
    //put it in the middle of screen in height
    pipe2.position = CGPointMake(60,20);
    
    [self addChild:pipe2];
    
    
    SKSpriteNode *pipe3 = [SKSpriteNode spriteNodeWithTexture:pipeUp];
    //[pipe setScale:0.8];
    //ship.zRotation = - M_PI / 2;
    
    //Adding SpriteKit physicsBody for collision detection
    pipe3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeUp.size];
    pipe3.physicsBody.categoryBitMask = groundPipeCategory;
    pipe3.physicsBody.dynamic = YES;
    [pipe3.physicsBody setMass:120];
    pipe3.physicsBody.contactTestBitMask = bombCategory | birdCategory;
    pipe3.physicsBody.collisionBitMask = bombCategory | birdCategory;//;3;
    pipe3.physicsBody.usesPreciseCollisionDetection = YES;
    pipe3.name = @"ground_pipe";
    
    //put it in the middle of screen in height
    pipe3.position = CGPointMake(100,20);
    
    [self addChild:pipe3];
    

    

}

- (void) updateScore
{
    
    scoreLabel.text = [NSString stringWithFormat:@"%@: %ld",NSLocalizedString(@"Score", @"Score"),(long)self.score];
    
    //every 10 score we increase the speed by this factor
    if(self.score % 10 ==0) {
        self.birdVelocity = self.birdVelocity + SCORE_SPEED_INCREASE_FACTOR;
    }
    
    
    if(premiumPurchased) {
        
        if(self.score>25 && self.nextLevel==2) { //pass to level 2 on 25
            [[[[iToast makeText:@"Good job!"]
               setGravity:iToastGravityTop] setDuration:1000] show];
            
            [self presentLevelLoaderView:2];
        }
        else if(self.score>50 && self.nextLevel==3) { //pass to level 3 at 50
            
            [[[[iToast makeText:@"Good job!"]
               setGravity:iToastGravityTop] setDuration:1000] show];
            
            [self presentLevelLoaderView:3];
        }
    }
    else {
        if(self.score == 15) {
            [[[[iToast makeText:@"Try to find the easter egg (Free Premium)!"]
               setGravity:iToastGravityTop] setDuration:1000] show];
        }
    }
    
}

-(void) setupStuff:(NSString *) backImage{
    
    
    backgroundImage = backImage;
    
    [self initalizingScrollingBackground];
    [self addFlyingPipe];
    [self addGroundPipe];
    [self createScore];
    [self createLifesString];
    
    self.lifes = NUM_LIFES;
    [self addLifes];
    
    self.groundPipes = NUM_LIFES;
    
    //Making self delegate of physics World
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    arrayOfParticles = [[NSMutableArray alloc] init];
    goingUp = true;
    
    flyingPipe.position = CGPointMake(160,160);
    
    [self setupPlayPause];
    self.nextLevel = 2;
    gamePaused = false;
    //increase velocity in -X by n
    birdVelocity = 0;
    
    
    


}

-(void) setupPlayPause {
    
    //------------------ SETUP TOUCH PLAY/PAUSE -----------------------------
 
    SKTexture* imgPause = [SKTexture textureWithImageNamed:@"pausebutton"];
    imgPause.filteringMode = SKTextureFilteringNearest;
    
    actionShowPauseButton = [SKAction animateWithTextures:@[imgPause] timePerFrame:0.2];
    
    SKTexture* imgPlay = [SKTexture textureWithImageNamed:@"playbutton"];
    imgPlay.filteringMode = SKTextureFilteringNearest;
    
    actionShowPlayButton = [SKAction animateWithTextures:@[imgPlay] timePerFrame:0.2];
    
    
    pauseButton = [SKSpriteNode spriteNodeWithTexture:imgPause];
    pauseButton.name=@"play_pause";
    [pauseButton setScale:0.6];
    pauseButton.position = CGPointMake(self.frame.size.width-100,self.size.height-40);
    [self addChild:pauseButton];

    
    //-----------------------------------------------------------------------
}



    


//random bird
-(int) getRandomBird: (int) max {
    return arc4random() % max;
}

-(int) getRandomSound:(int) max {
    return [self getRandomBird:max];
}

-(void)addFlappy
{

    //
    int color = [self getRandomBird:3]; //0,1 or 2
    CGRect texture1;
    CGRect texture2;
    CGRect texture3;
    
    switch (color) {
        case 0: //blue
            texture1 = BLUE_BIRD_CGRECT_1;
            texture2 = BLUE_BIRD_CGRECT_2;
            texture3 = BLUE_BIRD_CGRECT_3;
            break;
        case 1: //red
            texture1 = RED_BIRD_CGRECT_1;
            texture2 = RED_BIRD_CGRECT_2;
            texture3 = RED_BIRD_CGRECT_3;
            break;
            
        default: //yellow
            texture1 = YELLOW_BIRD_CGRECT_1;
            texture2 = YELLOW_BIRD_CGRECT_2;
            texture3 = YELLOW_BIRD_CGRECT_3;
            break;
    }
    
    
    NSString* rectAsString1 = NSStringFromCGRect( texture1 );
    NSString* rectAsString2 = NSStringFromCGRect( texture2);
    NSString* rectAsString3 = NSStringFromCGRect( texture3 );
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:rectAsString1];
    [array addObject:rectAsString2];
    [array addObject:rectAsString3];
    
    BirdNode *bird = [[BirdNode alloc] initWithSpriteSheetNamed:@"FlappyBirdSprites.png" withRect:array];
    
    [bird setScale:1.0];
    
    //Adding SpriteKit physicsBody for collision detection
    bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bird.size];
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.dynamic = YES;
    bird.physicsBody.contactTestBitMask = flyingPipeCategory | groundPipeCategory;
    bird.physicsBody.collisionBitMask = flyingPipeCategory | groundPipeCategory;//0;
    bird.physicsBody.usesPreciseCollisionDetection = YES;
    bird.name = @"flappy";
    bird.physicsBody.velocity= CGVectorMake(-(OBJECT_VELOCITY + birdVelocity), 0);
    
    //selecting random y position for bird
    int r = arc4random_uniform(330);
    bird.position = CGPointMake(self.frame.size.width + 20,r);
    
    [self addChild:bird];
    
    SKSpriteNode *bomb = [SKSpriteNode spriteNodeWithImageNamed:@"bomb"];
    [bomb setScale:0.6];
    bomb.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bird.size];
    bomb.physicsBody.categoryBitMask = bombCategory;
    bomb.physicsBody.dynamic = YES;
    bomb.physicsBody.contactTestBitMask = groundPipeCategory | flyingPipeCategory;
    bomb.physicsBody.collisionBitMask = groundPipeCategory | flyingPipeCategory;//2;
    bomb.physicsBody.usesPreciseCollisionDetection = YES;
    bomb.name = @"bomb";
    bomb.physicsBody.velocity= CGVectorMake(-(OBJECT_VELOCITY + birdVelocity), 0);
    bomb.position = CGPointMake(bird.position.x + (bird.size.width/2),bird.position.y +bird.size.height);
    
    [self addChild:bomb];

}

-(void) addLifes {
    
    CGRect texture1 = BLUE_BIRD_CGRECT_1;
    CGRect texture2 = BLUE_BIRD_CGRECT_2;
    CGRect texture3 = BLUE_BIRD_CGRECT_3;
    
    
    SKTexture  *ssTexture = [SKTexture textureWithImageNamed:@"FlappyBirdSprites.png"];
    ssTexture.filteringMode = SKTextureFilteringNearest;
    
    
    
    CGRect cutterOne = CGRectMake(texture1.origin.x
                               /ssTexture.size.width, texture1.origin.y/ssTexture.size.height, 38/ssTexture.size.width, 24/ssTexture.size.height);
    CGRect cutterTwo = CGRectMake(texture2.origin.x
                                  /ssTexture.size.width, texture2.origin.y/ssTexture.size.height, 38/ssTexture.size.width, 24/ssTexture.size.height);
    
    CGRect cutterThree = CGRectMake(texture3.origin.x
                                  /ssTexture.size.width, texture3.origin.y/ssTexture.size.height, 38/ssTexture.size.width, 24/ssTexture.size.height);
    
    //CGRect cutter = CGRectMake(sx, sy,sWidth,sHeight);
    SKTexture *lifeOne = [SKTexture textureWithRect:cutterOne inTexture:ssTexture];
    SKTexture *lifeTwo = [SKTexture textureWithRect:cutterTwo inTexture:ssTexture];
    SKTexture *lifeThree = [SKTexture textureWithRect:cutterThree inTexture:ssTexture];
    
    SKSpriteNode *birdOne = [SKSpriteNode spriteNodeWithTexture:lifeOne];
    SKSpriteNode *birdTwo = [SKSpriteNode spriteNodeWithTexture:lifeTwo];
    SKSpriteNode *birdThree = [SKSpriteNode spriteNodeWithTexture:lifeThree];
    
    [birdOne setScale:0.5];
    [birdTwo setScale:0.5];
    [birdThree setScale:0.5];
 
    [birdOne setPosition:CGPointMake(80, self.size.height - 30)];
    [birdTwo setPosition:CGPointMake(110, self.size.height - 30)];
    [birdThree setPosition:CGPointMake(140, self.size.height - 30)];
    
    [birdOne setName:@"lifeOne"];
    [birdTwo setName:@"lifeTwo"];
    [birdThree setName:@"lifeThree"];
    
    [self addChild:birdOne];
    [self addChild:birdTwo];
    [self addChild:birdThree];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    //handle pause touch
    if([node.name isEqualToString:@"play_pause"]) {

        [self updatePausePlayUI];
 
    }

    
    if(!self.view.isPaused) {
        if(touchLocation.y >flyingPipe.position.y){
            
            if(flyingPipe.position.y < 270){
                goingUp = true;
                
                SKAction *group = [SKAction group:@[actionMoveUp, actionUpdateMoveUpSprite]];
                [flyingPipe runAction:group];

            }
        }else{
            if(flyingPipe.position.y > 50){
                goingUp = false;
                
                SKAction *group = [SKAction group:@[actionMoveDown, actionUpdateMoveDownSprite]];
                [flyingPipe runAction:group];

            }
            
            
        }
    }

    
}

-(void) updatePausePlayUI {

 
    if(gamePaused) {
        [self.view setPaused:NO];
        [pauseButton runAction:actionShowPauseButton completion:^{
         gamePaused = self.view.isPaused;
        }];
        
    }
    else {
        [pauseButton runAction:actionShowPlayButton completion:^{
        [self.view setPaused:YES];
         gamePaused = self.view.isPaused;
        }];
        
    }

    
    


}

-(void)initalizingScrollingBackground
{

    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:backgroundImage];//backmy
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
    
}

- (void) createScore
{

    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    scoreLabel.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"Score", @"Score"),self.score];
    scoreLabel.name=@"score";
    scoreLabel.fontSize = 36;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 40);
    scoreLabel.alpha = 1;
    [self addChild:scoreLabel];
    
    
    
    
}



- (void) createLifesString
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    label.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"lifes", @"lifes")];
    label.name=@"lifes_string";
    label.fontSize = 16;
    label.position = CGPointMake(40, self.frame.size.height - 35);
    label.alpha = 1;
    [self addChild:label];
    
    
    
}

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
         
     }];
}

- (void)moveObstacle
{
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
        if ([node.name isEqual: @"flappy"] || [node.name isEqual:@"bomb"] ) {
            
            //NSLog(@"node name is %@",node.name);
            SKSpriteNode *spriteObj = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(spriteObj.physicsBody.velocity.dx, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            spriteObj.position = CGPointAdd(spriteObj.position, amtToMove);
            
            
            if(spriteObj.position.x < 120 ) {
                
                if([node.name isEqual:@"flappy"]) {
                    spriteObj.physicsBody.affectedByGravity = true;
                    CGPoint velocity = CGPointMake(0, OBJECT_VELOCITY);
                    CGPoint tMove = CGPointMultiplyScalar(velocity,_dt);
                    spriteObj.position = CGPointAdd(spriteObj.position, tMove);
                    
                }
                else if([node.name isEqual:@"bomb"]) {
                    spriteObj.physicsBody.affectedByGravity = true;
                    //[spriteObj.physicsBody setMass:50];ff
                    spriteObj.physicsBody.velocity = CGVectorMake(-15,-OBJECT_VELOCITY );
                }
                
                //drop the bombs
            }
            if(spriteObj.position.x < -100 || (spriteObj.position.x > self.frame.size.width && spriteObj.physicsBody.velocity.dx > 0) )
            {
                [spriteObj removeFromParent];
 
            }
            //if going right
            else if( (spriteObj.position.x > flyingPipe.position.x + 100) && spriteObj.physicsBody.velocity.dx > 0) {
                
                if([spriteObj.name isEqual:@"bomb"]) {
                    //explode the bomb
                    [self runAction:[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO]];
                    
                    ParticleEmitterNode * mySmokeParticle = [self addParticle:@"MySmokeParticle" andInterval:1];
                    mySmokeParticle.particle.particlePosition = spriteObj.position;
                    [self addChild:mySmokeParticle.particle];
                    
                    [spriteObj removeFromParent];
                }
                if([spriteObj.name isEqual:@"flappy"]) {
                    //burn the bird feathers
                    BirdNode *theBird = (BirdNode*)spriteObj;
                    theBird.isBurning = true;
                    [spriteObj runAction:pulseRed];
                    
                    ParticleEmitterNode * myFireParticle = [self addParticle:@"MyFireParticle" andInterval:0.5];
                    myFireParticle.particle.particlePosition = spriteObj.position;
                    myFireParticle.particle.emissionAngle = SK_RADIANS_TO_DEGREES(180);
                    [self addChild:myFireParticle.particle];

                }
                
        
                
                
            }
            
            

        }
        
    }
}

//remove the elapsed particles
-(void) removeParticles {
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(int i = 0; i <  arrayOfParticles.count; i++) {
        ParticleEmitterNode *node = [arrayOfParticles objectAtIndex:i];
        if([node checkIfRemoveParticle:_lastUpdateTime]) {
            [discardedItems addObject:node];
        }
        
    }
    
    [arrayOfParticles removeObjectsInArray:discardedItems];
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    if( currentTime - _lastBirdAdded > 1)
    {
        _lastBirdAdded = currentTime + 1;
        [self addFlappy];
    }

    
    [self moveBg];
    [self moveObstacle];
    [self removeParticles];
    
    
    

}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & flyingPipeCategory) != 0 &&
        (secondBody.categoryBitMask & birdCategory) != 0)
    {

        self.score +=1;
        [self updateScore];
        
        NSString *randomText = [self getRandomHitText];
        
        
        [[[[iToast makeText:randomText]
           setGravity:iToastGravityTop] setDuration:500] show];
        

        //TODO bounce birds with a given angle random
        SKAction *bounce = [SKAction sequence:@[actionRotateSwingBack,actionRotateSwingFront]];
        [flyingPipe runAction:bounce];
        
        [self runAction:[SKAction playSoundFileNamed:@"bounce.wav" waitForCompletion:NO]];
        secondBody.velocity = CGVectorMake(OBJECT_VELOCITY + BOUNCE_FORCE_FACTOR, 0);
        
        int randomBirdSound = [self getRandomSound:5];
        [self playSoundFile:randomBirdSound];
        
        //this would flip the sprites
        secondBody.node.xScale = secondBody.node.xScale * -1;
        [secondBody.node runAction:actionMoveFlappyRight];


    }
    if ((firstBody.categoryBitMask & flyingPipeCategory) != 0 &&
        (secondBody.categoryBitMask & bombCategory) != 0) {
        secondBody.velocity = CGVectorMake(OBJECT_VELOCITY + BOUNCE_FORCE_FACTOR, 0);
        //this would flip the bomb too
        secondBody.node.xScale = secondBody.node.xScale * -1;
        
    }
    //collision between bird and ground pipe
    if ((firstBody.categoryBitMask & birdCategory) != 0 &&
        (secondBody.categoryBitMask & groundPipeCategory) != 0) {
        
        int randomBirdSound = [self getRandomSound:5];
        [self playSoundFile:randomBirdSound];
        
        firstBody.velocity = CGVectorMake(0, -OBJECT_VELOCITY + BOUNCE_FORCE_FACTOR);
        
    }
    
    
    
    if ((firstBody.categoryBitMask & bombCategory) != 0 &&
        (secondBody.categoryBitMask & groundPipeCategory) != 0) {
        
        [self runAction:[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO]];
        ParticleEmitterNode * mySmokeParticle = [self addParticle:@"MySmokeParticle" andInterval:1];
        mySmokeParticle.particle.particlePosition = secondBody.node.position;
        [self addChild: mySmokeParticle.particle];
        
        [firstBody.node runAction:pulseRed];
        ParticleEmitterNode * myFireParticle = [self addParticle:@"MyFireParticle" andInterval:5000];
        myFireParticle.particle.particlePosition = secondBody.node.position;
        [self addChild: myFireParticle.particle];
        
        //remove the bomb
        [firstBody.node removeFromParent];
        [secondBody.node runAction: [SKAction repeatActionForever: changeToDarker]];
        
        //LOOSE LIFE
        [self decreaseLife];
        
        [self runAction:[SKAction playSoundFileNamed:@"Loose.wav" waitForCompletion:NO]];
        if(self.lifes==0 || self.groundPipes==0) {
            
            SKNode *lifeNodeToRemove =[self childNodeWithName:@"lifeOne"];
            if(lifeNodeToRemove!=nil) {
                [lifeNodeToRemove removeFromParent];
            }
            
            [Score registerScore:self.score];
            [flyingPipe removeFromParent];
            
            [self stopMusic];
            
            [self presentGameOverView];
            
        }
        else {
            
            [[[[iToast makeText:@"Oh no!..."]
               setGravity:iToastGravityCenter] setDuration:1000] show];
            
            
            SKNode *lifeNodeToRemove = nil;
            if(self.lifes==2) {
                lifeNodeToRemove =[self childNodeWithName:@"lifeThree"];
            }
            else if(self.lifes==1) {
                lifeNodeToRemove =[self childNodeWithName:@"lifeTwo"];
            }
            
            if(lifeNodeToRemove!=nil) {
                [lifeNodeToRemove removeFromParent];
            }
            
        }
        
    }
    
    
}

-(NSString *) getRandomHitText {
    int num = [self getRandomSound:5];
    NSString *msg = @"";
    switch (num) {
        case 0:
            msg = @"Poow!...";
            break;
        case 1:
            msg = @"Baang!...";
            break;
        case 2:
            msg = @"Zabamm!...";
            break;
        case 3:
            msg = @"Cabumm!...";
            break;
        default:
            msg = @"Eat that!...";
            break;
    }
    
    return msg;
}

//plays a random sound file
-(void) playSoundFile:(int) randomBirdSound {
    
    NSString *soundFile;
    switch (randomBirdSound) {
        case 0:
            soundFile = BIRD_SOUND_ONE;
            break;
        case 1:
            soundFile = BIRD_SOUND_TWO;
            break;
        case 2:
            soundFile = BIRD_SOUND_THREE;
            break;
        case 3:
            soundFile = BIRD_SOUND_FOUR;
            break;
        default:
            soundFile = BIRD_SOUND_FIVE;
            break;
    }
    
    [self runAction:[SKAction playSoundFileNamed:soundFile waitForCompletion:NO]];
}

//show game over, hide play/pause buttons
-(void) presentGameOverView {
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    GameOverScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
    gameOverScene.nextLevel = 1;
    [gameOverScene setupStuff];
    [self.view presentScene:gameOverScene transition: reveal];
    
    /*
    ViewController *root = (ViewController*)self.view.window.rootViewController;
    if(root!=nil) {
        [root showInterstitial];
    }*/
}

//show game over, hide play/pause buttons
-(void) presentLevelLoaderView:(NSInteger) next {
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    LevelLoader * levelLoaderScene = [LevelLoader sceneWithSize:self.size];
    levelLoaderScene.nextLevel = next;
    [levelLoaderScene setupStuff];
    //preserve current score
    levelLoaderScene.previousScore = self.score ;
    
    [self.view presentScene:levelLoaderScene transition: reveal];
}


@end
