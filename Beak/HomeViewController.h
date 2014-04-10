//
//  ViewController.h
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface HomeViewController : UIViewController <BeaconManagerDelegate>

@property (nonatomic, strong) IBOutlet UIView *loginView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (void)switchToggled:(UISwitch*)toggle;
- (IBAction)createGroup:(id)sender;
- (IBAction)manageGroup:(id)sender;

@end
