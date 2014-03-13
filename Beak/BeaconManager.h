//
//  BeaconManager.h
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeaconManager.h>

@protocol BeaconManagerDelegate <NSObject>

/**
 called on the delegate when message for entering a region is retrieved
 
 access properties of message as following:
 
 message[@"title"]
 message[@"body"]
 
 */

- (void)didReceiveEnteredRegionMessage:(PFObject *)message;

@end

@interface BeaconManager : NSObject <ESTBeaconManagerDelegate>

+ (BeaconManager*)sharedManager;

@property (nonatomic, weak) id <BeaconManagerDelegate> delegate;

- (void)getAvailableGroupsWithBlock:(void(^)(NSArray *groups, NSError *error))block;
- (void)monitorBeaconsForGroup:(NSString *)groupId;

/**
 
 method will return NSArray of ESTBeacon* to the block passed
 
 */

- (void)searchForNearbyBeacons:(void (^)(NSArray *beacons, NSError *error))block;

/**
 
 method to save a user generated group and associate it with beacons
 
 groupAttributes - NSDictionary with keys: name
 beacons - NSArray of NSDictionary's with keys: beacon(ESTBeacon object), messages(NSArray of NSDictionary with keys:title, body)
 
 */

- (void)saveNewGroup:(NSDictionary*)groupAttributes withBeacons:(NSArray*)beacons;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) NSMutableDictionary *monitoredRegions;

@end
