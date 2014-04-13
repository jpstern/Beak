//
//  SettingsViewController.m
//  Beak
//
//  Created by Josh Stern on 3/18/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ManageGroupsViewController.h"

#import "EditGroupViewController.h"
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[BeaconManager sharedManager] stopSearchingForBeacons];
    
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    
    [self findNearbyGroups];
    [self findSubscriptionGroups];
    
    /*[[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *beacons, NSError *error) {
        
        NSArray *beaconIds = [beacons valueForKeyPath:@"proximityUUID.UUIDString"];
        
        [[BeaconManager sharedManager] getGroupsForNearbyBeacons:beaconIds WithCompletion:^(NSArray *beacons) {
            
            NSSet *set = [NSSet setWithArray:[_nearby valueForKey:@"objectId"]];
            NSSet *set1 = [NSSet setWithArray:[beacons valueForKey:@"objectId"]];
            
            if (![set isEqualToSet:set1]) {
                
                _nearby = beacons;
//                [self reloadNearby];
            }
            
            [[BeaconManager sharedManager] getUserSubscribedGroups:^(NSArray *groups, NSError *error) {
                

                NSSet *set2 = [NSSet setWithArray:[_subscriptions valueForKey:@"objectId"]];
                NSSet *set3 = [NSSet setWithArray:[groups valueForKey:@"objectId"]];
                
                if (!_subscriptions || ![set2 isEqualToSet:set3]) {
                    
                    _subscriptions = groups;
                    
                    
//                    [self reloadSubscriptions];
                    
                    NSArray *subscriptionIds = [_subscriptions valueForKeyPath:@"group.objectId"];
                    
                    _nearby = [_nearby filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.objectId IN %@)", subscriptionIds]];
                    
                    [self.tableView reloadData];

                    
                }
                
            }];
            
        }];
        
    }];*/
    
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

- (void)findSubscriptionGroups {
    
    [[BeaconManager sharedManager] getUserSubscribedGroups:^(NSArray *groups, NSError *error) {
       
        _subscriptions = groups;
        
        [self.tableView reloadData];
    }];
}

- (void)findNearbyGroups {
    
    [[BeaconManager sharedManager] searchForNearbyGroups:^(NSArray *parseBeacons, NSError *error) {
        
        NSSet *subscriptionIds = [[NSSet alloc] initWithArray:[_subscriptions valueForKeyPath:@"group.objectId"]];
        NSMutableSet *objectIds = [[NSMutableSet alloc] init];
        NSMutableSet *groups = [[NSMutableSet alloc] init];
        
        for (PFObject *obj in parseBeacons) {
            
            if (![objectIds containsObject:[obj[@"group"] objectId]] && ![subscriptionIds containsObject:[obj[@"group"] objectId]]) {
                
                [objectIds addObject:[obj[@"group"] objectId]];
                [groups addObject:obj[@"group"]];
            }
        }
        
        NSSet *newIds = [NSSet setWithArray:[[groups allObjects] valueForKey:@"objectId"]];
        NSSet *oldIds = [NSSet setWithArray:[_nearby valueForKey:@"objectId"]];
        
        if (![newIds isEqualToSet:oldIds]) {
            
            _nearby = [groups allObjects];
            
            [self reloadNearby];
        }
        
    }];
}

- (void)monitorGroup:(ManageCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFObject *group = _nearby[indexPath.row];
    
    [[BeaconManager sharedManager] subscribeToGroup:group WithCompletion:^(PFObject *subscription) {
       
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSMutableArray *temp = [_subscriptions mutableCopy];
        [temp addObject:subscription];
        _subscriptions = temp;
        
        NSMutableArray *temp2 = [_nearby mutableCopy];
        [temp2 removeObjectAtIndex:indexPath.row];
        _nearby = temp2;
        
        [self.tableView reloadData];
        
    }];

}

#pragma mark UITableView stuff

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Unsubscribe";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 285, 44)];
    if (section == 0) {
        
        label.text = @"YOUR SUBSCRIPTIONS";
    }
    else {
        
        label.text = @"TAP A GROUP TO SUBSCRIBE";
    }
    
    label.textColor = [UIColor colorWithRed:0.427451 green:0.427451 blue:0.447059 alpha:1];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [view addSubview:label];
    
    if (section == 1) {
        
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
        
        return _subscriptions.count;
    }
    
    return _nearby.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"CellID";
    
    ManageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        
        cell = [[ManageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    }
    
    if (indexPath.section == 0) {
        
        if (_subscriptions.count == 0) {
            
            cell.noGroups = YES;
            cell.emptyLabel.text = @"No subscriptions";
        }
        else {
            
            cell.noGroups = NO;
            
            PFObject *subscription = _subscriptions[indexPath.row];
            
            [subscription fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
               
                PFObject *group = [subscription objectForKey:@"group"];
                [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    cell.textLabel.text = [object objectForKey:@"name"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ beacon%@", group[@"beaconCount"], [group[@"beaconCount"] intValue] == 1 ? @"" : @"s"];
                    
                    PFObject *user = group[@"user"];
                    
                    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        if ([user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
                            
                            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                        }
                    }];

                    
                }];
                
                //            }
                //            else if ([subscription.parseClassName isEqualToString:@"Group"]) {
                //
                //                cell.groupName.text = [subscription objectForKey:@"name"];
                //            }
                
            }];
            
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
                
                PFObject *owner = group[@"owner"];
                
                [owner fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if ([owner.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
                        
                        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                    }
                }];
                
                [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    cell.textLabel.text = [group objectForKey:@"name"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ beacon%@", group[@"beaconCount"], [group[@"beaconCount"] intValue] == 1 ? @"" : @"s"];
                }];
                
            }];
            
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *group = nil;
    
    if (indexPath.section == 0) {
        
        group = _subscriptions[indexPath.row][@"group"];
        
    }
    else if (indexPath.section == 1) {
        
        group = _nearby[indexPath.row];
        
    }
    
    EditGroupViewController *editGroup = [self.storyboard instantiateViewControllerWithIdentifier:@"editGroupViewController"];
    editGroup.group = group;
    editGroup.edit = YES;
    [self.navigationController pushViewController:editGroup animated:YES];
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
    
//    if (_subscriptions.count == 0) {
//        
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//    else {
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    
    [tableView reloadData];
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
