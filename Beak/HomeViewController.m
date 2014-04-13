//
//  ViewController.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "HomeViewController.h"
#import "BeaconTableDelegate.h"

@interface HomeViewController () <ESTBeaconManagerDelegate> {
    
    BOOL contentShown;
}

@property (nonatomic, strong) BeaconManager *beaconManager;
@property (nonatomic, strong) BeaconTableDelegate *tableDelegate;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation HomeViewController

- (void)showProfile {

    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {

        if (!user) {

            NSLog(@"Uh oh. The user cancelled the Facebook login.");

        } else if (user.isNew) {

            NSLog(@"User signed up and logged in through Facebook!");

        } else {

            NSLog(@"User logged in through Facebook!");
        }
        
    }];
    
}

- (void)openRight {
    
    [self.viewDeckController toggleRightViewAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BeaconManager sharedManager] setDelegate:self];
    
    _imageView.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side"] style:UIBarButtonItemStylePlain target:self action:@selector(openRight)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [[BeaconManager sharedManager] getExistingMessagesForUser:^(NSArray *messages, NSError *error) {
        
        NSLog(@"%@", messages);
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didEnterRegion {
    
    
}

- (void)didReceiveEnteredRegionMessage:(PFObject *)message {
    
}

@end
