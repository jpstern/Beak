//
//  ViewController.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ViewController.h"

#import "BeaconManager.h"

@interface ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) BeaconManager *beaconManager;


@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSSet *activeGroups;

@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    _activeGroups = [def objectForKey:@"activeGroups"];
    
    [[BeaconManager sharedManager] getAvailableGroupsWithBlock:^(NSArray *groups, NSError *error) {
        
        _groups = groups;
        
        [_tableView reloadData];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToggled:(UISwitch*)toggle {
    
    PFObject *group = _groups[toggle.tag];
    
    [[BeaconManager sharedManager] monitorBeaconsForGroup:group.objectId];
}

#pragma mark UITableView

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
    
    if ([_activeGroups containsObject:group.objectId]) {
        
        active.on = YES;
    }
    else {
        
        active.on = NO;
    }
    
    cell.textLabel.text = [group objectForKey:@"name"];
    
    return cell;
}


@end
