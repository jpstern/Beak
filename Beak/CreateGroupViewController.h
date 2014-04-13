//
//  CreateGroupViewController.h
//  Beak
//
//  Created by Girish Hari on 3/17/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface CreateGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(strong,nonatomic) UITextField *enterGroupName;
@property (nonatomic, strong) IBOutlet UITableView *tableView;


@end
