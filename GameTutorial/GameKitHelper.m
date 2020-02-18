//
//  GameKitHelper.m
//  RevengeOfClones
//
//  Created by Paulo Cristo on 16/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "GameKitHelper.h"

@implementation GameKitHelper

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
// Add to the top of the file
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
@synthesize enableGameCenter;

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    NSLog(@"authenticating on game center...");
    //1
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    // Add this between the 1st and 2nd step of authenticateLocalPlayer
    if (localPlayer.isAuthenticated) {
        NSLog(@"already authenticated");
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        return;
    }
    
    //2
    localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
        //3
        [self setLastError:error];
        
        if(viewController != nil) {
            //4
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            //5
            //5
            enableGameCenter = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        } else {
            //6
            enableGameCenter = NO;
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PresentAuthenticationViewController
         object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@",
              [[_lastError userInfo] description]);
    }
}



@end
