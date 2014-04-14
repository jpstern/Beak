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
    
    BOOL onceToken;
}

@property (nonatomic, strong) UIView *noGroupsView;
@property (nonatomic, strong) UILabel *noContent;

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

- (UIView *)noGroupsView {
    
    [_noGroupsView removeFromSuperview];
    
    if (!_noGroupsView) {
        
        _noGroupsView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 248)];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 60)];
        title.text = @"Looks like you haven't joined a group yet!";
        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        [_noGroupsView addSubview:title];
        
        UIButton *join = [UIButton buttonWithType:UIButtonTypeCustom];
        join.frame = CGRectMake(10, 100, 300, 44);
        join.backgroundColor = [UIColor lightGrayColor];
        [join setTitle:@"Join a Group!" forState:UIControlStateNormal];
        [join addTarget:self action:@selector(manageGroup) forControlEvents:UIControlEventTouchUpInside];
        [join.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [_noGroupsView addSubview:join];
        
        UILabel *or = [[UILabel alloc] initWithFrame:CGRectMake(10, 164, 300, 20)];
        or.text = @"Or";
        or.numberOfLines = 0;
        or.textAlignment = NSTextAlignmentCenter;
        or.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        or.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
        [_noGroupsView addSubview:or];
        
        UIButton *create = [UIButton buttonWithType:UIButtonTypeCustom];
        create.frame = CGRectMake(10, 204, 300, 44);
        create.backgroundColor = [UIColor lightGrayColor];
        [create setTitle:@"Create Your Own!" forState:UIControlStateNormal];
        [create.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [create addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
        [_noGroupsView addSubview:create];
    }
    
    return _noGroupsView;
}

- (UILabel *)noContent {
    
    if (!_noContent) {
        
        _noContent = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 60)];
        _noContent.text = @"Nothing to see here yet";
        _noContent.numberOfLines = 0;
        _noContent.textAlignment = NSTextAlignmentCenter;
        _noContent.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        _noContent.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        [_noGroupsView addSubview:_noContent];

    }
    
    return _noContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    onceToken = [def boolForKey:@"previewRight"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BeaconManager sharedManager] setDelegate:self];
    
    _imageView.hidden = YES;
    
    self.title = @"Beak";
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side"] style:UIBarButtonItemStylePlain target:self action:@selector(openRight)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.viewDeckController setPanningMode:IIViewDeckFullViewPanning];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (![def boolForKey:@"subscribedToGroups"]) {
        
        [self.view addSubview:[self noGroupsView]];
        
    }
    else {
        
        [[BeaconManager sharedManager] getUserSubscribedGroups:^(NSArray *groups, NSError *error) {
            
            for (PFObject *sub in groups) {
            
                [[BeaconManager sharedManager] monitorBeaconsForGroup:sub[@"group"]];
            }
            
            [self.tableView reloadData];
        }];

        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                            init];
        [refreshControl addTarget:self action:@selector(callRefresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
        
        [self callRefresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!onceToken) {
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setBool:YES forKey:@"previewRight"];
        [def synchronize];
        
        [self.viewDeckController openRightViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
            
            [self performSelector:@selector(closeRight) withObject:nil afterDelay:0.5];
            
        }];
    }
}

- (void)closeRight {
    
    [self.viewDeckController closeRightView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didEnterRegion {
    
    NSLog(@"entered region");
}

- (void)didReceiveEnteredRegionMessage:(PFObject *)message {
    
    NSLog(@"%@", message);
    
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
    //UIView *refreshView =[UIView alloc];
    [self.refreshControl beginRefreshing];
    
    [[BeaconManager sharedManager] getExistingMessagesForUser:^(NSArray *messages, NSError *error) {
        
        _messages = messages;
        
        //if there are no messages show create and manage button
        if(messages.count==0) {

            [self.view addSubview:[self noContent]];

        }
        else {
            
            [_noGroupsView removeFromSuperview];
            [self.tableView reloadData];
            //[refreshView dealloc];
        }
        [self.refreshControl endRefreshing];
    }];
    //return refreshView;
}

//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    return 44;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"Messages count %ld",self.messages.count);

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if(_messages.count>0)
    {
        PFObject *temp =self.messages[indexPath.row];
        [temp[@"message"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            cell.textLabel.text =object[@"body"];
        }];
    
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}


@end
