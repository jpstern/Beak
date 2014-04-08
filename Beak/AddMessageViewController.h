//
//  AddMessageViewController.h
//  Beak
//
//  Created by Josh Stern on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMessageViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) PFObject *beaconObj;
@property (nonatomic, strong) NSString *beaconName;

@end
