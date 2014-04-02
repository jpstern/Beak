//
//  ManageCell.h
//  Beak
//
//  Created by Josh Stern on 3/31/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageCell : UITableViewCell

@property (nonatomic, strong) UILabel  *emptyLabel;

@property (nonatomic, strong) UILabel  *groupName;
@property (nonatomic, strong) UILabel  *beaconCount;

@property (nonatomic, strong) UISwitch *active;

@property (nonatomic, assign) BOOL noGroups;


@end
