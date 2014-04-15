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

#import "HomeCell.h"

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

@property (nonatomic, strong) NSMutableDictionary *textSizeMap;

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
    
    [_noContent removeFromSuperview];
    
    if (!_noContent) {

        _noContent = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 60)];
        _noContent.text = @"Nothing to see here!";
        _noContent.numberOfLines = 0;
        _noContent.textAlignment = NSTextAlignmentCenter;
        _noContent.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        _noContent.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
//        [_noGroupsView addSubview:_noContent];

    }
    
    return _noContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BeaconManager sharedManager] setDelegate:self];
    
    _imageView.hidden = YES;
    
    self.title = @"Beak";
    
    _textSizeMap = [[NSMutableDictionary alloc] init];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side"] style:UIBarButtonItemStylePlain target:self action:@selector(openRight)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    onceToken = [def boolForKey:@"previewRight"];
    
    [self.viewDeckController setPanningMode:IIViewDeckFullViewPanning];
    
    if (![def boolForKey:@"subscribedToGroups"]) {
        
        [self.view addSubview:[self noGroupsView]];
        
    }
    else {
        
        [[BeaconManager sharedManager] getUserSubscribedGroups:^(NSArray *groups, NSError *error) {
            
            if (groups.count == 0) {
                
                [def setBool:NO forKey:@"subscribedToGroups"];
                
                [_noContent removeFromSuperview];
                [self.view addSubview:[self noGroupsView]];
            }
            
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
    [self callRefresh];
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

- (void)processMessages {
    
//    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
    
    for (PFObject *userMessage in _messages) {
        
        if (groups[[userMessage[@"group"] objectId]]) {
            
            NSMutableArray *arr = groups[[userMessage[@"group"] objectId]];
            
            [arr addObject:userMessage];
        }
        else {
            
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:userMessage, nil];
            groups[[userMessage[@"group"] objectId]] = arr;
        }
    }
    
    _messages = [groups allValues];
    
    
}

-(void)callRefresh
{
    //UIView *refreshView =[UIView alloc];
    [self.refreshControl beginRefreshing];
    
    [[BeaconManager sharedManager] getExistingMessagesForUser:^(NSArray *messages, NSError *error) {
        
        _messages = messages;
        
        [self processMessages];
        
        //if there are no messages show create and manage button
        if(messages.count==0) {

            [_noGroupsView removeFromSuperview];
            [self.view addSubview:[self noContent]];

        }
        else {
            
            [_noContent removeFromSuperview];
            [_noGroupsView removeFromSuperview];
        }
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    //return refreshView;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    view.backgroundColor = [[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1] colorWithAlphaComponent:0.6];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
    lab.textColor = [UIColor darkTextColor];
    lab.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    [view addSubview:lab];
    
    PFObject *userMessage = _messages[section][0];
    
    [userMessage[@"group"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
       
        lab.text = [NSString stringWithFormat:@"Messages from %@", object[@"name"]];
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *message = _messages[indexPath.section][indexPath.row];
    
    if ([message[@"type"] isEqualToString:@"text"]) {
        
        return _textSizeMap[message.objectId] ? MAX(44, [_textSizeMap[message.objectId] floatValue]+ 5) : 44;
    }
    
    return 320;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"Messages count %ld",self.messages.count);

    return _messages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages[section] count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellID";
    
    HomeCell *cell;// = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if (!cell) {
    
        cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//    }
    
    PFObject *userMessage = self.messages[indexPath.section][indexPath.row];
    
    if ([userMessage[@"type"] isEqualToString:@"text"]) {
        
        [userMessage[@"message"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            
            NSString *text = object[@"body"];
//            
            CGSize size = [text sizeWithFont:cell.body.font constrainedToSize:CGSizeMake(300, 9999)];
//            CGRect rect = [text boundingRectWithSize:CGSizeMake(300, 999) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: cell.body.font} context:nil];
            
            NSNumber *curHeight = _textSizeMap[userMessage.objectId];
            
            if (![curHeight isEqual:@(size.height)]) {
                _textSizeMap[userMessage.objectId] = @(size.height);
                [tableView reloadData];
            }
            
            CGRect frame = cell.body.frame;
            frame.size.height = MAX(44, size.height);
            cell.body.frame = frame;
            
            cell.body.text = object[@"body"];
            
//            PFObject *group = userMessage[@"group"];
//            [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                
//                cell.title.text = [NSString stringWithFormat:@"%@ has something for you!", object[@"name"]];
//            }];
            
            
        }];
    }
    else {
        
        [userMessage[@"message"] fetchIfNeededInBackgroundWithBlock:^(PFObject *message, NSError *error){
            
            PFFile *theImage = message[@"imageFile"];
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                cell.messageImage.image = image;
            }];
        }];

        
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}


@end
