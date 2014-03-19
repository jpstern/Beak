//
//  ViewController.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "HomeViewController.h"
#import "BeaconTableDelegate.h"


@interface HomeViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) BeaconManager *beaconManager;
@property (nonatomic, strong) BeaconTableDelegate *tableDelegate;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[BeaconManager sharedManager] setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
//        
//        if (!user) {
//            
//            NSLog(@"Uh oh. The user cancelled the Facebook login.");
//            
//        } else if (user.isNew) {
//            
//            NSLog(@"User signed up and logged in through Facebook!");
//            
//        } else {
//            
//            NSLog(@"User logged in through Facebook!");
//        }
//        
//    }];
    
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

- (void)didReceiveEnteredRegionMessage:(PFObject *)message
{
    self.title = message[@"title"];
    _textView.text = message[@"body"];
    NSLog(@"%@", _textView.text);
}

@end
