//
//  CreateGroupViewController.m
//  Beak
//
//  Created by Girish Hari on 3/17/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "CreateGroupViewController.h"

@interface CreateGroupViewController ()


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
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellID"];
    
//    UILabel *beaconTableText=[[UILabel alloc]initWithFrame:CGRectMake(20, 160, 280, 20)];
//    beaconTableText.text=@"Beacons Available:";
//    [self.view addSubview:beaconTableText];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    _enterGroupName = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
//    _enterGroupName.borderStyle = UITextBorderStyleLine;
    _enterGroupName.placeholder = @"Enter group name here";
    [headerView addSubview:self.enterGroupName];
    
    _tableView.tableHeaderView = headerView;
    
    UIBarButtonItem *saveButton=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(goToSave)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
 
    [[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *beacons, NSError *error) {
        
        NSSet *set = [NSSet setWithArray:[_beaconsList valueForKey:@"proximityUUID"]];
        NSSet *set1 = [NSSet setWithArray:[beacons valueForKey:@"proximityUUID"]];
        
        if (![set isEqual:set1]) {
            
            _beaconsList = beacons;
            [_tableView reloadData];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (IBAction)quitButtonClicked:(id)sender {
    NSLog(@"quitclicked");
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

- (void)goToSave{
    
    NSLog(@"goToSave!");
    if(self.enterGroupName.text.length==0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid group name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //[alert release];
    }
    
    //self.enterGroupName
    //if(groupNameInput.text.length>0)
    //{
     
     //   [[[BeaconManager sharedManager]saveNewGroup:<#(NSDictionary *)#> withBeacons:<#(NSArray *)#>]
     //    {
             
            //
     //    }];
        //groupName.text=groupNameInput.text;
    //}
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    if (section == 0) {
        
        label.text = @"NEARBY BEACONS";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _beaconsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 235, 0, 0)];
    [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView=mySwitch;
    
    ESTBeacon *beacon = self.beaconsList[indexPath.row];
    
    cell.textLabel.text = beacon.proximityUUID.UUIDString;
    NSNumber *major=beacon.major;
    NSNumber *minor=beacon.minor;
    NSString *temp=[NSString stringWithFormat:@"Major:%@ Minor:%@",major,minor];
    cell.detailTextLabel.text=temp;
    
    
    return cell;
}


- (void)changeSwitch:(id)sender{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
    }
}
@end
