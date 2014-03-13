//
//  ViewController.h
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface ViewController : UIViewController <BeaconManagerDelegate>

@property (nonatomic, strong) IBOutlet UIView *loginView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)switchToggled:(UISwitch*)toggle;

@end
