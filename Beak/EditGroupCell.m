//
//  EditGroupCell.m
//  Beak
//
//  Created by Josh Stern on 4/3/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "EditGroupCell.h"

@implementation EditGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _beaconName = [[UITextField alloc] initWithFrame:CGRectZero];
        _beaconName.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_beaconName];
        
        _subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitle.font = [UIFont systemFontOfSize:12];
//        [self.contentView addSubview:_subtitle];
        
        _count = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_count];
        
        _message = [UIButton buttonWithType:UIButtonTypeCustom];
        [_message setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        _message.tintColor = [UIColor blueColor];
        [self.contentView addSubview:_message];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _beaconName.frame = CGRectMake(15, 9, 240, 24);
    CGRect rect = self.detailTextLabel.frame;
    rect.origin.y = 33;
    self.detailTextLabel.frame = rect;
    
//    _subtitle.frame = CGRectMake(10, 34, 240, 20);
    _message.frame = CGRectMake(270, (self.contentView.frame.size.height - 44) / 2, 44, 44);
    
    CGSize size = [_count.text sizeWithAttributes:@{NSFontAttributeName: _count.font}];
    
    _count.frame = CGRectMake(_message.frame.origin.x - size.width - 5, (self.contentView.frame.size.height - 24) / 2, size.width, 24);
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
