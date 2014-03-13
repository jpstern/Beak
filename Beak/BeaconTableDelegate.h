//
//  BeaconTableDelegate.h
//  Beak
//
//  Created by Josh Stern on 3/10/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end
