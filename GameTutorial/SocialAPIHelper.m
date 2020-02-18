//
//  SocialAPIHelper.m
//  revengeofclones
//
//  Created by Paulo Cristo on 10/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "SocialAPIHelper.h"
#import "iToast.h"
#import <Social/Social.h>

@implementation SocialAPIHelper

+ (SocialAPIHelper *)sharedInstance; {
    
    static dispatch_once_t once;
    static SocialAPIHelper * sharedInstance;
    
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    
    
    return sharedInstance;
}



//will send the message to facebook
- (void)sendToFacebook: (NSString *) message fromView:(UIViewController *) rootController{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:message]; 
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"80"]];
        
        [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/revenge-of-the-clones/id859897918?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString *msg;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = @"Post canceled";
                    break;
                case SLComposeViewControllerResultDone:
                    msg = @"Post successful";
                    break;
                    
                default:
                    break;
            }
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
            
        }];
        
        //UIViewController *vc = self.view.window.rootViewController;
        [rootController  presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

//send the message also to twitter
- (void)sendToTwitter: (NSString *) message fromView:(UIViewController *) rootController{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString *url = @"https://itunes.apple.com/us/app/revenge-of-the-clones/id859897918?ls=1&mt=8";
        [mySLComposerSheet setInitialText: [NSString stringWithFormat:@"%@ %@",message,url]];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"80"]];
        
        [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/revenge-of-the-clones/id859897918?ls=1&mt=8"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            
            NSString *msg;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    msg = @"Post canceled";
                    break;
                case SLComposeViewControllerResultDone:
                    msg = @"Post successful";
                    break;
                    
                default:
                    break;
            }
            
            
            //we need to dismiss manually for twitter
            //[mySLComposerSheet dismissViewControllerAnimated:YES completion:nil];
            
            if(msg!=nil) {
                [[[[iToast makeText:msg]
                   setGravity:iToastGravityBottom] setDuration:1000] show];
            }
            
        }];
        
        //UIViewController *vc = self.view.window.rootViewController;
        [rootController presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

+(BOOL) canSendToFacebook {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}
+(BOOL) canSendToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

@end
