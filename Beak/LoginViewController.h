//
//  LoginViewController.h
//  Beak
//
//  Created by Neil Sood on 4/13/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *fblogin;

@end
