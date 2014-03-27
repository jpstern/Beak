//
//  SettingsViewController.m
//  Beak
//
//  Created by Josh Stern on 3/18/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ManageGroupsViewController.h"
#import "BeaconManager.h"

@interface ManageGroupsViewController ()

@property (nonatomic, strong) NSArray *groups;

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
    
    self.title = @"Available Groups";
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 320, 44);
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"Create a Group" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showCreateGroupController) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    
    self.tableView.tableFooterView = footerView;
    
    [[BeaconManager sharedManager] getAvailableGroupsWithBlock:^(NSArray *groups, NSError *error) {
        
        _groups = groups;
        
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCreateGroupController {
    
    [self performSegueWithIdentifier:@"createGroupSegue" sender:self];
}

- (void)switchToggled:(UISwitch*)toggle {
    
    PFObject *group = _groups[toggle.tag];
    
    [[BeaconManager sharedManager] monitorBeaconsForGroup:group.objectId];
}

#pragma mark UITableView stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    PFObject *group = _groups[indexPath.row];
    
    UISwitch *active = [[UISwitch alloc] init];
    active.tag = indexPath.row;
    [active addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    active.center = CGPointMake(270, 22);
    [cell.contentView addSubview:active];
    
    //    if ([_activeGroups containsObject:group.objectId]) {
    //
    //        active.on = YES;
    //    }
    //    else {
    //
    //        active.on = NO;
    //    }
    
    cell.textLabel.text = [group objectForKey:@"name"];
    
    return cell;
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
