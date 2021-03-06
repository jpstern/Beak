//
//  BeaconManager.h
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeaconManager.h"

@protocol BeaconManagerDelegate <NSObject>

/**
 called on the delegate when message for entering a region is retrieved
 
 access properties of message as following:
 
 message[@"title"]
 message[@"body"]
 
 */

- (void)didReceiveEnteredRegionMessage:(PFObject *)message;

- (void)didEnterRegion;

@end

@interface BeaconManager : NSObject <ESTBeaconManagerDelegate>

+ (BeaconManager*)sharedManager;

@property (nonatomic, weak) id <BeaconManagerDelegate> delegate;

- (void)saveDummyObject;

- (void)useDeviceAsBeacon;

- (void)subscribeToGroup:(PFObject *)groupObj WithCompletion:(void (^)(PFObject *subscription))block;

- (void)stopMonitoringRegionsForGroupId:(NSString*)groupId;

- (void)getUserOwnedGroups:(void (^)(NSArray *groups, NSError *error))block;
- (void)getUserSubscribedGroups:(void (^)(NSArray *groups, NSError *error))block;

- (void)getGroupsForNearbyBeacons:(NSArray *)beaconIds WithCompletion:(void (^)(NSArray *beacons))block;

- (void)getAvailableGroupsWithBlock:(void(^)(NSArray *groups, NSError *error))block;
- (void)monitorBeaconsForGroup:(PFObject *)groupObj;

- (void)getBeaconsForGroup:(PFObject*)group andCompletion:(void (^)(NSArray *beacons, NSError *error))block;

- (void)getWelcomeMessageForGroup:(PFObject *)groupObj andCompletion:(void (^)(PFObject *message, NSError *error))block;

- (void)searchForNearbyGroups:(void (^)(NSArray *parseBeacons, NSError *error))block;
/**
 
 method will return NSArray of ESTBeacon* and NSArray of PFObjects (Beacon) to the block passed
 
 */
- (void)searchForNearbyBeacons:(void (^)(NSArray *estBeacons, NSArray *parseBeacons, NSError *error))block;
//- (void)searchForNearbyBeacons:(void (^)(NSArray *beacons, NSError *error))block;
- (void)stopSearchingForBeacons;

- (void)getExistingMessagesForUser:(void (^)(NSArray *messages, NSError *error))block;

/**
 
 method to save a user generated group and associate it with beacons
 
 groupAttributes - NSDictionary with keys: name
 beacons - NSArray of NSDictionary's with keys: beacon(ESTBeacon object), messages(NSArray of NSDictionary with keys:title, body)
 
 */

- (void)saveNewGroup:(NSDictionary*)groupAttributes withBeacons:(NSArray*)beacons;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) NSMutableDictionary *monitoredRegions;

//for create session

@property (nonatomic, strong) NSArray *estBeacons;
@property (nonatomic, strong) NSMutableDictionary *currentMessages; //estbeacon -> nsarray of messages

@end
