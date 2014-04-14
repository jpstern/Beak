//
//  MenuTableViewCell.m
//  Beak
//
//  Created by Josh Stern on 4/1/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.numberOfLines = 0;
        _title.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        _title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
        [self.contentView addSubview:_title];

    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _title.center = CGPointMake(250, self.contentView.bounds.size.height / 2);
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
