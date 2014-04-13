//
//  ViewController.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "HomeViewController.h"
#import "BeaconTableDelegate.h"
#import "CreateGroupViewController.h"
#import "ManageGroupsViewController.h"

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(callRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BeaconManager sharedManager] setDelegate:self];
    
    _imageView.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side"] style:UIBarButtonItemStylePlain target:self action:@selector(openRight)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self callRefresh];
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

-(void)createGroup
{
    NSLog(@"goToCG!");
    CreateGroupViewController *createGroup = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewController"];
    [self.navigationController pushViewController:createGroup animated:YES];
}

-(void)manageGroup
{
    NSLog(@"goToMG!");
    ManageGroupsViewController *manageGroup =[self.storyboard instantiateViewControllerWithIdentifier:@"manageViewController"];
    [self.navigationController pushViewController:manageGroup animated:YES];
}

-(void)callRefresh
{
    [self.refreshControl beginRefreshing];
    [[BeaconManager sharedManager] getExistingMessagesForUser:^(NSArray *messages, NSError *error) {
        
        //if there are no messages show create and manage button
        if(messages.count==0)
        {
            UIButton *createGroupButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [createGroupButton addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
            [createGroupButton setTitle:@"Create a Group" forState:UIControlStateNormal];
            createGroupButton.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
            [self.view addSubview:createGroupButton];
            
            UIButton *manageGroupButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [manageGroupButton addTarget:self action:@selector(manageGroup) forControlEvents:UIControlEventTouchUpInside];
            [manageGroupButton setTitle:@"Manage Group" forState:UIControlStateNormal];
            manageGroupButton.frame = CGRectMake(80.0, 250.0, 160.0, 40.0);
            [self.view addSubview:manageGroupButton];
            
        }
        NSLog(@"%@", messages);
        [self.refreshControl endRefreshing];
    }];

}

@end
