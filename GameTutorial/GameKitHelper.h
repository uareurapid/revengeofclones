//
//  GameKitHelper.h
//  RevengeOfClones
//
//  Created by Paulo Cristo on 16/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

@import GameKit;

@protocol GameKitHelperDelegate
- (void) showLeaderboard;
- (void) submitScore:(NSInteger) score;
@end

@interface GameKitHelper : NSObject

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property BOOL enableGameCenter;
extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;


+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;

@end
