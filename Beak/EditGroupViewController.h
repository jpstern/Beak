//
//  EditGroupViewController.h
//  Beak
//
//  Created by Josh Stern on 4/3/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditGroupViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, strong) PFObject *group;

@property (nonatomic, assign) BOOL useDevice;
@property (nonatomic, assign) BOOL edit;

@end
