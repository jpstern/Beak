//
//  CreateGroupViewController.h
//  Beak
//
//  Created by Girish Hari on 3/17/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface CreateGroupViewController : UIViewController
{
    IBOutlet UITextField *groupNameInput;
    IBOutlet UIBarButtonItem *saveButton;
    IBOutlet UILabel *groupName;
    NSMutableArray *beaconsList;
}
@property(strong,nonatomic) UITextField *groupNameInput;
@property(strong,nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UITableView *beaconTableView;

- (IBAction)quitButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;





@end
