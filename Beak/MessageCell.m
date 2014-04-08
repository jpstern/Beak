//
//  MessageCell.m
//  Beak
//
//  Created by Josh Stern on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _message = [[UITextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_message];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _message.frame = CGRectMake(0, 0, 320, self.contentView.frame.size.height);
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
