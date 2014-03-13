//
//  BeaconTableDelegate.m
//  Beak
//
//  Created by Josh Stern on 3/10/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "BeaconTableDelegate.h"

@implementation BeaconTableDelegate


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
    [active addTarget:_target action:_selector forControlEvents:UIControlEventValueChanged];
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



@end
