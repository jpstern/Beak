//
//  HomeCell.m
//  Beak
//
//  Created by Josh Stern on 4/14/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UILabel *)title {
    
    if (!_title) {
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        _title.textColor = [UIColor darkTextColor];
        _title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        
        [self.contentView addSubview:_title];
    
    }
    
    return _title;
}

- (UILabel *)body {
    
    if (!_body) {
        
        _body = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
        _body.numberOfLines = 0;
        _body.textColor = [UIColor darkTextColor];
        _body.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [self.contentView addSubview:_body];
    }
    
    return _body;
}

- (UIImageView *)messageImage {
    
    if (!_messageImage) {
        
        _messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [self.contentView addSubview:_messageImage];
    }
    
    return _messageImage;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
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
