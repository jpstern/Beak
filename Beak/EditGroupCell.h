//
//  EditGroupCell.h
//  Beak
//
//  Created by Josh Stern on 4/3/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditGroupCell : UITableViewCell

@property (nonatomic, strong) UITextField *beaconName;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UIButton *message;
@property (nonatomic, strong) UILabel *count;

@end
