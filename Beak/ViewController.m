//
//  ViewController.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ViewController.h"
#import "BeaconTableDelegate.h"

@interface ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) BeaconManager *beaconManager;
@property (nonatomic, strong) BeaconTableDelegate *tableDelegate;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    _activeGroups = [def objectForKey:@"activeGroups"];
    
    [[BeaconManager sharedManager] getAvailableGroupsWithBlock:^(NSArray *groups, NSError *error) {
        
        _tableDelegate.groups = groups;
        
        [_tableView reloadData];
    }];
    
    _tableDelegate = [[BeaconTableDelegate alloc] init];
    _tableDelegate.selector = @selector(switchToggled:);
    _tableDelegate.target = self;
    _tableView.delegate = _tableDelegate;
    _tableView.dataSource = _tableDelegate;

    
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

@end
