//
//  BeaconManager.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "BeaconManager.h"

typedef void (^NearbyBeaconsBlock)(NSArray *, NSError *);

@interface BeaconManager () {
    
    NearbyBeaconsBlock nearbyBlock;
}

@property (nonatomic, strong) ESTBeaconRegion *currentRegion;

@end

@implementation BeaconManager

+ (BeaconManager *)sharedManager {
    
    static BeaconManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedClient = [[BeaconManager alloc] init];

    });
    
    return sharedClient;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = YES;
        
    }
    
    return self;
}

- (void)saveDummyObject {
    
    PFObject *group = [[PFObject alloc] initWithClassName:@"Group"];
    [group setObject:[PFUser currentUser] forKey:@"owner"];
    [group setObject:@"this is the name" forKey:@"name"];
    [group setObject:@[@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] forKey:@"beaconIDs"];
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self saveDummyBeaconForGroup:group];
    }];
}

- (void)saveDummyBeaconForGroup:(PFObject*)group {
    
    PFObject *beacon = [[PFObject alloc] initWithClassName:@"Beacon"];
    [beacon setObject:group forKey:@"group"];
    [beacon setObject:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" forKey:@"beaconId"];
    [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    }];
    
//    PFObject *beacon2 = [[PFObject alloc] initWithClassName:@"Beacon"];
//    [beacon2 setObject:group forKey:@"group"];
//    [beacon2 setObject:@"4321" forKey:@"beaconId"];
//    [beacon2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//    }];
}

- (void)subscribeToGroup:(PFObject *)groupObj WithCompletion:(void (^)(PFObject *))block {
    
    PFObject *subscription = [[PFObject alloc] initWithClassName:@"Subscription"];
    [subscription setObject:[PFUser currentUser] forKey:@"user"];
    [subscription setObject:groupObj forKey:@"group"];
    
    [subscription saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        block (subscription);
    }];
}

- (void)getUserSubscribedGroups:(void (^)(NSArray *, NSError *))block {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Subscription" predicate:[NSPredicate predicateWithFormat:@"user == %@", [PFUser currentUser]]];
    
    [query findObjectsInBackgroundWithBlock:block];
    
}

- (void)getGroupsForNearbyBeacons:(NSArray *)beaconIds WithCompletion:(void (^)(NSArray *))block {
    
    
    NSMutableSet *groupSet = [[NSMutableSet alloc] init];
    NSMutableSet *groupIDSet = [[NSMutableSet alloc] init];
    
    __block NSInteger returnCount = 0;
    for (NSString *beaconID in beaconIds) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Beacon" predicate:[NSPredicate predicateWithFormat:@"beaconId == %@", beaconID]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            PFObject *group = objects[0][@"group"];
            
            if (![groupIDSet containsObject:group.objectId]) {
                
                [groupIDSet addObject:group.objectId];
                [groupSet addObject:group];
            }
            
            [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                
            }];
            
            returnCount ++;
            
            if (returnCount == beaconIds.count) {
                
                block([groupSet allObjects]);
            }
        }];
        
    }
    
}

- (void)getAvailableGroupsWithBlock:(void (^)(NSArray *, NSError *))block {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSLog(@"%@", objects);
        }
        else {
            
            NSLog(@"%@", error);
        }
        
        block(objects, error);
        
    }];
    
}

- (void)monitorBeaconsForGroup:(NSString *)groupId {

    PFQuery *query = [PFQuery queryWithClassName:@"Beacon" predicate:[NSPredicate predicateWithFormat:@"SELF.groupId == %@", groupId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (!error) {
            
            for (PFObject *beacon in objects) {
                
                NSString *uuid = [beacon objectForKey:@"proximityUUID"];
                NSNumber *major = [beacon objectForKey:@"majorValue"];
                NSNumber *minor = [beacon objectForKey:@"minorValue"];
                
                if (uuid && major && minor) {
                    
                    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                                                       major:major.intValue minor:minor.intValue
                                                                                  identifier:beacon.objectId];
                    [self.beaconManager startMonitoringForRegion:region];
                    [self.beaconManager requestStateForRegion:region];

                    
                }
                
            }
        }
        
    }];
    
}

- (void)stopSearchingForBeacons {
    
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"ranging"];
    [self.beaconManager stopRangingBeaconsInRegion:region];
//    [self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)searchForNearbyBeacons:(void (^)(NSArray *, NSError *))block {
    
    nearbyBlock = block;
    
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"ranging"];
    [self.beaconManager startRangingBeaconsInRegion:region];
//    [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:region];

}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    
    nearbyBlock(beacons, nil);
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    
    nearbyBlock(nil, error);
}

- (void)validateBeaconInput:(NSArray *)beacons {
    
    for (NSDictionary *dict in beacons) {
        
        NSAssert([dict isKindOfClass:[NSDictionary class]], @"argument 2 (beacons) must be an array of NSDictionaries, you passed %@", NSStringFromClass([dict class]));
        NSAssert([dict[@"beacon"] isKindOfClass:[ESTBeacon class]], @"object at key ""beacon"" is not of type ESTBeacon");
        NSAssert([dict[@"messages"] isKindOfClass:[NSArray class]], @"object at key ""messages"" is not of type NSArray");
        
        for (NSDictionary *message in dict[@"messages"]) {
            
            NSAssert(message[@"title"], @"message has no title");
            NSAssert(message[@"body"], @"message has no body");
        }
        
    }
}

- (void)saveNewGroup:(NSDictionary *)groupAttributes
         withBeacons:(NSArray *)beacons {
    
    NSAssert(groupAttributes != nil, @"argument 1 (groupAttributes) must be non-nil");
    NSAssert(beacons != nil && beacons.count != 0, @"argument 2 (beacons) must be non-nil and contain at least 1 element");
    NSAssert(groupAttributes[@"name"] != nil, @"argument 1 (groupAttributes) must contain a name key");
    
    [self validateBeaconInput:beacons];
    
    
    
    PFObject *group = [[PFObject alloc] initWithClassName:@"Group"];
    [group setObject:[PFUser currentUser] forKey:@"owner"];
    [group setObject:groupAttributes[@"name"] forKey:@"name"];
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if (succeeded) {
            
            for (NSDictionary *beaconDict in beacons) {
            
                ESTBeacon *beaconObj = beaconDict[@"beacon"];
                
                PFObject *beacon = [[PFObject alloc] initWithClassName:@"Beacon"];
                [beacon setObject:beaconObj.major forKey:@"majorValue"];
                [beacon setObject:beaconObj.minor forKey:@"minorValue"];
                [beacon setObject:[beaconObj.proximityUUID UUIDString] forKey:@"proximityUUID"];
                [beacon setObject:group.objectId forKey:@"groupId"];
                [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                    for (NSDictionary *messageDict in beaconDict[@"messages"]) {
                        
                        PFObject *messageObj = [[PFObject alloc] initWithClassName:@"Group"];
                        [messageObj setObject:beacon.objectId forKey:@"beaconId"];
                        [messageObj setObject:messageDict[@"title"] forKey:@"title"];
                        [messageObj setObject:messageDict[@"body"] forKey:@"body"];
                        [messageObj saveInBackground];
                        
                    }
                }];
                
            }
            
        }
        else {
            
            NSLog(@"%@", error);
        }
        
    }];
    
}

- (void)getInformationForEnteredRegion:(ESTBeaconRegion*)region {
    
    [_delegate didEnterRegion];
    
    NSNumber *major = region.major;
    NSNumber *minor = region.minor;
    NSString *uuid = [region.proximityUUID UUIDString];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon" predicate:[NSPredicate predicateWithFormat:@"proximityUUID == %@ AND majorValue == %@ AND minorValue == %@", uuid, major, minor]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && objects.count > 0 && !error) {
            
            PFObject *beacon = objects[0];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Message" predicate:[NSPredicate predicateWithFormat:@"beaconId == %@", beacon.objectId]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"%@", error);
                }
                else if (objects && objects.count > 0) {
                    
                    PFObject *message = objects[0];
                    
                    [_delegate didReceiveEnteredRegionMessage:message];
                }
                
            }];
            
        }
        else if (error) {
            
            NSLog(@"%@", error);
        }
        
        
    }];
    
}

#pragma mark ESTBeaconManager Delegate

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside) {
        
        _currentRegion = region;
        
        [self getInformationForEnteredRegion:region];
        
        
    }
    else {
        
        _currentRegion = nil;
    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    
    [self getInformationForEnteredRegion:region];
    
// present local notification
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"Enter";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{

// present local notification
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"The shoes you'd tried on are now 20%% off for you with this coupon";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}




@end
