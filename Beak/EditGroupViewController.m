//
//  EditGroupViewController.m
//  Beak
//
//  Created by Josh Stern on 4/3/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "EditGroupViewController.h"

#import "AddMessageViewController.h"

#import "EditGroupCell.h"

@interface EditGroupViewController () {
    
    UITextField *activeField;
}

@end

@implementation EditGroupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)saveGroup {
    
    [activeField resignFirstResponder];
    
    NSDictionary *currentMessages = [[[BeaconManager sharedManager] currentMessages] copy];
    
    [[BeaconManager sharedManager] setCurrentMessages:nil];
    [[BeaconManager sharedManager] setEstBeacons:nil];
    
    _group[@"beaconCount"] = @(_beacons.count);
    
    [_group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
        for (PFObject *beacon in _beacons) {
            
            NSString *mapId = [NSString stringWithFormat:@"%@%@", beacon[@"minor"], beacon[@"major"]];
            
            NSArray *messages = currentMessages[mapId];
            
            beacon[@"group"] = _group;
            [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                for (PFObject *message in messages) {
                    
                    message[@"beacon"] = beacon;
                    [message saveInBackground];
                }
                
            }];
        }
        
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSArray *arr = [[BeaconManager sharedManager] estBeacons];
    if (arr) {
        NSMutableArray *beacons = [[NSMutableArray alloc] init];
        for (ESTBeacon *estBeacon in arr) {
            PFObject *beacon = [[PFObject alloc] initWithClassName:@"Beacon"];
            beacon[@"proximityUUID"] = estBeacon.proximityUUID.UUIDString;
            beacon[@"major"] = estBeacon.major;
            beacon[@"minor"] = estBeacon.minor;
            [beacons addObject:beacon];
        }
        
        _beacons = beacons;
    }
    
    [self.tableView registerClass:[EditGroupCell class] forCellReuseIdentifier:@"CellID"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveGroup)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    
    if (!_beacons) {
        
        [[BeaconManager sharedManager] getBeaconsForGroup:_group andCompletion:^(NSArray *beacons, NSError *error) {
            
            _beacons = beacons;
            
            [self.tableView reloadData];
            
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addMessage:(UIButton *)button {
    
    NSInteger index = button.tag;
    
    PFObject *beacon = _beacons[index];
    
    AddMessageViewController *addMessage = [self.storyboard instantiateViewControllerWithIdentifier:@"addMessageViewController"];
    addMessage.beaconObj = beacon;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addMessage];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    PFObject *beacon = _beacons[textField.tag];
    beacon[@"name"] = textField.text;
    
    activeField = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _beacons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.beaconName.tag = indexPath.row;
    cell.beaconName.delegate = self;
    cell.message.tag = indexPath.row;
    [cell.message addTarget:self action:@selector(addMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    PFObject *beacon = _beacons[indexPath.row];
    
    NSNumber *major = beacon[@"major"];
    NSNumber *minor = beacon[@"minor"];
    NSString *temp = [NSString stringWithFormat:@"Major: %@ Minor: %@", major, minor];
    cell.detailTextLabel.text = temp;
        
    cell.count.text = [NSString stringWithFormat:@"(%@)", beacon[@"messageCount"] ? beacon[@"messageCount"] : @(0)];
    
    if (beacon.objectId) {
        
        [beacon fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (object[@"name"])
                cell.beaconName.text = object[@"name"];// ? object[@"name"] : @"Name this beacon";
            else
                cell.beaconName.placeholder = @"Name this beacon";
        }];
    }
    else {
        
        cell.beaconName.placeholder = @"Name this beacon";
    }
    
  


    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PFObject *beacon = _beacons[indexPath.row];
        
        if (beacon.objectId)
            [beacon deleteInBackground];
        
        NSMutableArray *beaconsMutable = [_beacons mutableCopy];
        [beaconsMutable removeObjectAtIndex:indexPath.row];
        _beacons = beaconsMutable;
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
