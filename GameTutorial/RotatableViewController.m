//
//  RotatableViewController.m
//  RevengeOfClones
//
//  Created by Paulo Cristo on 19/04/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "RotatableViewController.h"

@interface RotatableViewController ()

@end

@implementation RotatableViewController

@synthesize appStoreID,storeController,storeOpen;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andAppID:(NSString *) appID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appStoreID = appID;
        self.title=@"PC Dreams Software";
        storeOpen = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.view.alpha=0;
    [self openAppStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//empty method, the ones having it can rotate
- (void)canRotate { }

#pragma OPEN APP STORE

/**
-(IBAction)hideStoreView:(id)sender {
    NSLog(@"hide store");
    [storeController dismissViewControllerAnimated:YES completion:^{[self.navigationController popToRootViewControllerAnimated:YES];}];
}*/

-(void)openAppStore {
    //easymessage 668776671
    //flapi @"837165900";
    if(storeController==nil) {
        storeController = [[SKStoreProductViewController alloc] init];
    }
    
    
    storeController.delegate = self;
    
    NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : appStoreID };
    [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
        //Handle response
        
        NSLog(@"Do something here %d",result);
        if(result && !storeOpen) {
            [self presentViewController:storeController animated:YES completion:nil];
            storeOpen = true;
        }
    }];
}

//-(void) viewDidDisappear:(BOOL)animated {
  //  [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    NSLog(@"did finish store");
    if(storeController!=nil)
    [storeController dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];


}

@end
