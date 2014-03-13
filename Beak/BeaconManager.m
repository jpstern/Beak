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

- (void)searchForNearbyBeacons:(void (^)(NSArray *, NSError *))block {
    
    nearbyBlock = block;
    
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"ranging"];
    
    [self.beaconManager startMonitoringForRegion:region];
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    
    nearbyBlock(beacons, nil);
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    
    nearbyBlock(nil, error);
}

- (void)saveNewGroup:(NSDictionary *)groupAttributes
         withBeacons:(NSArray *)beacons {
    
    PFObject *group = [[PFObject alloc] initWithClassName:@"Group"];
    [group setObject:groupAttributes[@"name"] forKey:@"name"];
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if (succeeded) {
            
            for (ESTBeacon *beaconObj in beacons) {
            
                PFObject *beacon = [[PFObject alloc] initWithClassName:@"Beacon"];
                [beacon setObject:beaconObj.major forKey:@"majorValue"];
                [beacon setObject:beaconObj.minor forKey:@"minorValue"];
                [beacon setObject:[beaconObj.proximityUUID UUIDString] forKey:@"proximityUUID"];
                [beacon setObject:group.objectId forKey:@"groupId"];
                [beacon saveInBackground];
            }
            
        }
        else {
            
            NSLog(@"%@", error);
        }
        
    }];
    
}

- (void)getInformationForEnteredRegion:(ESTBeaconRegion*)region {
    
    
}

#pragma mark ESTBeaconManager Delegate

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside) {
        
        _currentRegion = region;
        
    }
    else {
        
        _currentRegion = nil;
    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    
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
