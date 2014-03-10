//
//  BeaconManager.m
//  Beak
//
//  Created by Josh Stern on 3/9/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "BeaconManager.h"

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
        
        /////////////////////////////////////////////////////////////
        // setup Estimote beacon manager
        
        // craete manager instance
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = YES;
        
        // create sample region with major value defined

//        ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
//                                                                           major:5648 minor:40385
//                                                                      identifier: @"EstimoteSampleRegion"];
        
//        NSLog(@"TODO: Update the ESTBeaconRegion with your major / minor number and enable background app refresh in the Settings on your device for the NotificationDemo to work correctly.");
        
        // start looking for estimote beacons in region
        // when beacon ranged beaconManager:didEnterRegion:
        // and beaconManager:didExitRegion: invoked
        
//        [self.beaconManager startMonitoringForRegion:region];
//        
//        [self.beaconManager requestStateForRegion:region];
        
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

#pragma mark ESTBeaconManager Delegate

-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {

    }
    else
    {

    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    
    // iPhone/iPad entered beacon zone
//    [self setProductImage];
    
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
    // iPhone/iPad left beacon zone
//    [self setDiscountImage];
    
    // present local notification
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"The shoes you'd tried on are now 20%% off for you with this coupon";
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}




@end
