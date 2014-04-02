//
//  SettingsViewController.m
//  Beak
//
//  Created by Josh Stern on 3/18/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ManageGroupsViewController.h"
#import "BeaconManager.h"

#import "ManageCell.h"

@interface ManageGroupsViewController ()

@property (nonatomic, strong) NSArray *nearby;
@property (nonatomic, strong) NSArray *subscriptions;

@end

@implementation ManageGroupsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismissView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Manage Groups";
    
//    [[BeaconManager sharedManager] getAvailableGroupsWithBlock:^(NSArray *groups, NSError *error) {
//        
//        _groups = groups;
//        
//        [self.tableView reloadData];
//    }];
}

- (void)reloadSubscriptions {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadNearby {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)filterNearby {
    
    NSArray *array = [[_subscriptions valueForKey:@"group"] valueForKey:@"objectId"];
    
//    NSMutableArray *temp2 = [_nearby mutableCopy];
//    [temp2 removeObjectsInArray:array];
//    _nearby = temp2;
    
//    _nearby = [_nearby filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.objectId IN %@)", array]];
    
    [self reloadNearby];
    [self reloadSubscriptions];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *beacons, NSError *error) {
//       
//        NSArray *beaconIds = [beacons valueForKey:@"proximityUUID"];
    
    NSArray *beaconIds = @[@"1234", @"4321"];
    
    [[BeaconManager sharedManager] getGroupsForNearbyBeacons:beaconIds WithCompletion:^(NSArray *beacons) {
        
        _nearby = beacons;
        
        [self reloadNearby];
        
        [[BeaconManager sharedManager] getUserSubscribedGroups:^(NSArray *groups, NSError *error) {
            
            _subscriptions = groups;
            
            [self reloadSubscriptions];
            
//            [self filterNearby];
        }];
        
    }];
    
//    }];
    
//    [[BeaconManager sharedManager] getAvailableGroupsWithBlock:^(NSArray *groups2, NSError *error) {
//        
//        _nearby = groups2;
//        
//        [self reloadNearby];
//        
////        if (_subscriptions) {
////            
////            [self filterNearby];
////        }
//        
//    }];

    

//    [[BeaconManager sharedManager] saveDummyObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)monitorGroup:(ManageCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFObject *group = _nearby[indexPath.row];
    
    [[BeaconManager sharedManager] subscribeToGroup:group WithCompletion:^(PFObject *subscription) {
       
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [[_subscriptions mutableCopy] addObject:group];
        
        NSMutableArray *temp = [_subscriptions mutableCopy];
        [temp addObject:subscription];
        _subscriptions = temp;
        
        NSMutableArray *temp2 = [_nearby mutableCopy];
        [temp2 removeObjectAtIndex:indexPath.row];
        _nearby = temp2;
        
        [self.tableView beginUpdates];
        
        if (_subscriptions.count == 0) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_subscriptions.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (_nearby.count == 0) {
        
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self.tableView endUpdates];
    }];
    
    
}

#pragma mark UITableView stuff

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Unsubscribe";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"YOUR GROUPS";
    }
    
    return @"ADD A NEARBY GROUP";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return _subscriptions.count;// ? _subscriptions.count : _subscriptions ? 1 : 0;
    }
    
    return _nearby.count;// ? _nearby.count : _nearby ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"CellID";
    
    ManageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        
        cell = [[ManageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    }
    
    if (indexPath.section == 0) {
        
        if (_subscriptions.count == 0) {
            
            cell.noGroups = YES;
            cell.emptyLabel.text = @"No subscriptions";
        }
        else {
            
            cell.noGroups = NO;
            
            PFObject *subscription = _subscriptions[indexPath.row];
            
            if ([subscription.parseClassName isEqualToString:@"Subscription"]) {
                
                PFObject *group = [subscription objectForKey:@"group"];
                [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    cell.groupName.text = [object objectForKey:@"name"];
                    
                }];
                
            }
            else if ([subscription.parseClassName isEqualToString:@"Group"]) {
                
                cell.groupName.text = [subscription objectForKey:@"name"];
            }
        }
    }
    else {
        
        if (_nearby.count == 0) {
            
            cell.noGroups = YES;
            cell.emptyLabel.text = @"No subscriptions";
        }
        else {
            
            PFObject *group = _nearby[indexPath.row];
            
            [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.groupName.text = [group objectForKey:@"name"];
            }];
            
            
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        ManageCell *cell = (ManageCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        [self monitorGroup:cell];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *subscription = _subscriptions[indexPath.row];
    
    [subscription deleteInBackground];
    
    NSMutableArray *temp = [_subscriptions mutableCopy];
    [temp removeObjectAtIndex:indexPath.row];
    _subscriptions = temp;
    
    if (_subscriptions.count == 0) {
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return YES;
    }
    
    return NO;
}

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
