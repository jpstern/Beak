//
//  BeaconManager.h
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeaconManager.h>


@interface BeaconManager : NSObject <ESTBeaconManagerDelegate>

+ (BeaconManager*)sharedManager;

- (void)getAvailableGroupsWithBlock:(void(^)(NSArray *groups, NSError *error))block;
- (void)monitorBeaconsForGroup:(NSString *)groupId;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) NSMutableDictionary *monitoredRegions;

@end
