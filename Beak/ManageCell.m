//
//  ManageCell.m
//  Beak
//
//  Created by Josh Stern on 3/31/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "ManageCell.h"

@implementation ManageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyLabel.frame = CGRectMake(0, 0, 260, 20);
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont systemFontOfSize:12];
        _emptyLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:_emptyLabel];
        
        _groupName = [[UILabel alloc] initWithFrame:CGRectZero];
        _groupName.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:_groupName];
        
        _active = [[UISwitch alloc] init];
//        [self.contentView addSubview:_active];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (_noGroups) {
        
        _active.hidden = YES;
        _emptyLabel.center = CGPointMake(160, self.contentView.frame.size.height / 2);
        _groupName.hidden = YES;
    }
    else {
        
        _active.hidden = NO;
        _active.center = CGPointMake(280, self.contentView.frame.size.height / 2);
        
        _groupName.hidden = NO;
        _groupName.frame = CGRectMake(10, 12, 200, 20);
        
        _emptyLabel.hidden = YES;
    }

}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
