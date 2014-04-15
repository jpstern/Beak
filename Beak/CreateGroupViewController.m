//
//  CreateGroupViewController.m
//  Beak
//
//  Created by Girish Hari on 3/17/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "CreateGroupViewController.h"

#import "EditGroupViewController.h"

@interface CreateGroupViewController ()

@property (nonatomic, assign) BOOL shouldUseThisDevice;
@property (strong, nonatomic) NSArray *beaconsList;
@property (strong, nonatomic) NSSet *usedBeaconIds;
@property (nonatomic, strong) NSMutableSet *selectedBeacons;
@end

@implementation CreateGroupViewController

//@synthesize groupNameInput;
//@synthesize saveButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[BeaconManager sharedManager] stopSearchingForBeacons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellID"];
    
//    UILabel *beaconTableText=[[UILabel alloc]initWithFrame:CGRectMake(20, 160, 280, 20)];
//    beaconTableText.text=@"Beacons Available:";
//    [self.view addSubview:beaconTableText];
    
    [self.viewDeckController setPanningMode:IIViewDeckNoPanning];
    
    _selectedBeacons = [[NSMutableSet alloc] init];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    _enterGroupName = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
//    _enterGroupName.borderStyle = UITextBorderStyleLine;
    _enterGroupName.returnKeyType = UIReturnKeyDone;
    [_enterGroupName addTarget:_enterGroupName action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    _enterGroupName.placeholder = @"Enter group name here";
    [headerView addSubview:self.enterGroupName];
    
    _tableView.tableHeaderView = headerView;
    
    UIBarButtonItem *saveButton=[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goToEditScreen)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
 
    [[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *estBeacons, NSArray *parseBeacons, NSError *error) {
        
//        estBeacons = [estBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.proximityUUID.UUIDString IN %@)", [parseBeacons valueForKey:@"proximityUUID"]]];
       
        NSSet *set = [NSSet setWithArray:[_beaconsList valueForKey:@"proximityUUID"]];
        NSSet *set1 = [NSSet setWithArray:[estBeacons valueForKey:@"proximityUUID"]];
        
        if (![set isEqual:set1]) {
            
            _usedBeaconIds = [NSSet setWithArray:[parseBeacons valueForKey:@"minor"]];
            _beaconsList = estBeacons;
            [_tableView reloadData];
            
        }
        
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[BeaconManager sharedManager] setCurrentMessages:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToEditScreen {
    
    [[BeaconManager sharedManager] setEstBeacons:[_selectedBeacons allObjects]];
    
    PFObject *group = [[PFObject alloc] initWithClassName:@"Group"];
    group[@"owner"] = [PFUser currentUser];
    group[@"name"] = _enterGroupName.text;
    
    EditGroupViewController *editGroup = [self.storyboard instantiateViewControllerWithIdentifier:@"editGroupViewController"];
    editGroup.group = group;
    editGroup.useDevice = _shouldUseThisDevice;
    [self.navigationController pushViewController:editGroup animated:YES];
}

- (void)goToSave{
    
    NSLog(@"goToSave!");
    if(self.enterGroupName.text.length==0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid group name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //[alert release];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    if (section == 0) {
        
        label.text = @"SELECT YOUR BEACONS";
    }

    label.textColor = [UIColor colorWithRed:0.427451 green:0.427451 blue:0.447059 alpha:1];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [view addSubview:label];
    
    if (section == 0) {
        
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = CGPointMake(label.frame.origin.x + size.width + 20, label.center.y);
        [indicator startAnimating];
        [view addSubview:indicator];
        
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return _beaconsList.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        
        ESTBeacon *beacon = self.beaconsList[indexPath.row];
        
        BOOL used = NO;
        
        if ([_usedBeaconIds containsObject:beacon.minor]) {
            
            used = YES;
            
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
        
        if ([_selectedBeacons containsObject:beacon]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.accessoryView = nil;
        
        cell.textLabel.text = [NSString stringWithFormat:@"Beacon %d %@", (indexPath.row + 1), used ? @"- Already Used" : @""];

        NSNumber *major = beacon.major;
        NSNumber *minor = beacon.minor;
        NSString *temp = [NSString stringWithFormat:@"Major: %@ Minor: %@", major, minor];
        cell.detailTextLabel.text = temp;
    }
    else {
        
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [mySwitch addTarget:self action:@selector(useDeviceToggled:) forControlEvents:UIControlEventValueChanged];
        [mySwitch setOn:_shouldUseThisDevice];
        cell.accessoryView = mySwitch;
        
        cell.textLabel.text = @"Use this device as a beacon";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ESTBeacon *beacon = _beaconsList[indexPath.row];
    
    if (![_usedBeaconIds containsObject:beacon.proximityUUID.UUIDString]) {
        
        if (![_selectedBeacons containsObject:beacon]) {
            
            [_selectedBeacons addObject:beacon];
        }
        else {
            
            [_selectedBeacons removeObject:beacon];
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)useDeviceToggled:(UISwitch*)sw {
    
    if (sw.isOn) {
        
        _shouldUseThisDevice = YES;
    }
    else {
        
        _shouldUseThisDevice = NO;
    }
}

@end
