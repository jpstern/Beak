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
    
    [self.viewDeckController openRightViewAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0 green:135/255.0 blue:60/255.0 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20], NSForegroundColorAttributeName: [UIColor whiteColor]}];

    
    [[BeaconManager sharedManager] setDelegate:self];
    
    _imageView.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side"] style:UIBarButtonItemStylePlain target:self action:@selector(openRight)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToggled:(UISwitch*)toggle {

    PFObject *group = _tableDelegate.groups[toggle.tag];
    
    [[BeaconManager sharedManager] monitorBeaconsForGroup:group.objectId];
}

- (void)didEnterRegion {
    
    if (!contentShown) {
        
        self.title = @"Loading Content!";
        _textView.text = @"";
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = CGPointMake(160, self.view.frame.size.height / 2);
        [self.view addSubview:_indicator];
        
        [_indicator startAnimating];
    }
}

- (void)didReceiveEnteredRegionMessage:(PFObject *)message {
    
    [_indicator removeFromSuperview];
    _indicator = nil;
    
    self.title = message[@"title"];
    _textView.text = message[@"body"];
    NSLog(@"%@", _textView.text);
    
    contentShown = YES;
    _imageView.hidden = NO;
    
}

@end
