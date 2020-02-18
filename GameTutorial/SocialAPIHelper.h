//
//  SocialAPIHelper.h
//  revengeofclones
//
//  Created by Paulo Cristo on 10/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialAPIHelper : NSObject

@property (strong,nonatomic) UIViewController *rootViewController;

+ (SocialAPIHelper *)sharedInstance;

//-(id) initWithRootViewController: (UIViewController *) rootController;
- (void)sendToFacebook: (NSString *) message fromView:(UIViewController *) rootController;
- (void)sendToTwitter: (NSString *) message fromView:(UIViewController *) rootController;

+(BOOL) canSendToFacebook;
+(BOOL) canSendToTwitter;
@end
