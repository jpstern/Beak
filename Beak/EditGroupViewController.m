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
    UITextView *joinMessage;
}

@property (nonatomic, strong) PFObject *welcomeMessage;
@property (nonatomic, strong) NSDictionary *deviceBeacon;

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

- (void)deleteGroup {
    
    [_group deleteInBackground];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveGroup {
    
    [activeField resignFirstResponder];
    
    if ([[BeaconManager sharedManager] currentMessages][@"joinMessage"]) {
//    if (![joinMessage.text isEqualToString:@"(Optional) Add a message for when a user subscribes"]) {
    
        _group[@"hasJoinMessage"] = @(YES);
        
        PFObject *mess = [PFObject objectWithClassName:@"Message"];
        mess[@"body"] = joinMessage.text;
        mess[@"isJoinMessage"] = @(YES);
        mess[@"group"] = _group;
        [mess saveInBackground];
        
    }
    
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
        
        if (_useDevice) {
            
            PFObject *beacon = [[PFObject alloc] initWithClassName:@"Beacon"];
            beacon[@"proximityUUID"] = [ESTIMOTE_IOSBEACON_PROXIMITY_UUID UUIDString];
            beacon[@"major"] = @(89898);
            beacon[@"minor"] = @(10101);
            beacon[@"isUserDevice"] = @(YES);
            [beacons addObject:beacon];
        }
        
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

- (void)textViewDidChange:(UITextView *)textView {
    
    if (![textView.text isEqualToString:@"(Optional) Add a message for when a user subscribes"] && textView.text.length != 0) {
    
        [[[BeaconManager sharedManager] currentMessages] setObject:textView.text forKey:@"joinMessage"];
        
    }
    else {
        
        [[[BeaconManager sharedManager] currentMessages] removeObjectForKey:@"joinMessage"];
    }
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"(Optional) Add a message for when a user subscribes"]) {
        
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        
        textView.text = @"(Optional) Add a message for when a user subscribes";
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _edit ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    if (section == 1)
        return _beacons.count;
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) return 150;
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        BOOL hasWelcome = [_group[@"hasJoinMessage"] boolValue];
        
        if (!hasWelcome && ![[BeaconManager sharedManager] currentMessages][@"joinMessage"] && !_welcomeMessage) {
            cell.joinMessage.text = @"(Optional) Add a message for when a user subscribes";
        }
        else {
            
            NSString *newMessage = [[BeaconManager sharedManager] currentMessages][@"joinMessage"];
            
            if (newMessage) {
                cell.joinMessage.text = newMessage;
            }
            else {
                
                [[BeaconManager sharedManager] getWelcomeMessageForGroup:_group andCompletion:^(PFObject *message, NSError *error) {
                   
                    [message fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        cell.joinMessage.text = object[@"body"];
                        
                    }];
                    
                }];
                
            }
        }
        cell.joinMessage.delegate = self;
        
        joinMessage = cell.joinMessage;

    }
    else if (indexPath.section == 1) {
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.message.hidden = NO;
        cell.count.hidden = NO;
        cell.beaconName.hidden = NO;
        cell.beaconName.tag = indexPath.row;
        cell.beaconName.delegate = self;
        cell.message.tag = indexPath.row;
        [cell.message addTarget:self action:@selector(addMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        if (NSLocationInRange(indexPath.row, NSMakeRange(0, _beacons.count))) {
            
            PFObject *beacon = _beacons[indexPath.row];
            
            if (beacon[@"isUserDevice"]) {
                
                cell.count.text = [NSString stringWithFormat:@"(%@)", beacon[@"messageCount"] ? beacon[@"messageCount"] : @(0)];
                
                cell.beaconName.text = [[UIDevice currentDevice] name];
                cell.detailTextLabel.text = @"iOS Device";
            }
            else {
                
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
                
                cell.textLabel.text = @"";
            }
        }
    }
    else {
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        cell.beaconName.hidden = YES;
        cell.message.hidden = YES;
        cell.count.hidden = YES;
        cell.textLabel.text = @"Delete Group";
        cell.textLabel.textColor = [UIColor redColor];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        
        [self deleteGroup];
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
