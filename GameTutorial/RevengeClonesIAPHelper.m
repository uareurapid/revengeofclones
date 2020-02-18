//
//  EasyMessageIAPHelper.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/7/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "RevengeClonesIAPHelper.h"

@interface RevengeClonesIAPHelper ()

@end

@implementation RevengeClonesIAPHelper

//The sharedInstance method implements the Singleton pattern in Objective-C to return a single,
//global instance of the RageIAPHelper class. It calls the superclasses initializer to pass in all
//the product identifiers that you created with iTunes Connect.

+ (RevengeClonesIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RevengeClonesIAPHelper * sharedInstance;
    
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:PRODUCT_REVENGE_CLONES_PREMIUM, nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end
