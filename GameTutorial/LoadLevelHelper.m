//
//  LoadLevelHelper.m
//  revengeofclones
//
//  Created by Paulo Cristo on 10/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "LoadLevelHelper.h"
#import "iToast.h"

@implementation LoadLevelHelper

+ (LoadLevelHelper *)sharedInstance; {
    
    static dispatch_once_t once;
    static LoadLevelHelper * sharedInstance;
    
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


    



@end
