//
//  LoginViewController.m
//  Beak
//
//  Created by Neil Sood on 4/13/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "LoginViewController.h"
#import "MyViewDeckViewController.h"

#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, strong) UILabel *welcome;
@property (nonatomic, strong) UILabel *desc;

@property (nonatomic, strong) UILabel *question;

@property (nonatomic, strong) UIButton *whatBeacons;
@property (nonatomic, strong) UIButton *haveBeacons;
@property (nonatomic, strong) UIButton *joinGroup;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIButton *back;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *facebook;

@end

@implementation LoginViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([PFUser currentUser] && // Check if a user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) // Check if user is linked to Facebook
    {
        [self userLoggedIn];
        
    }
}

- (void)showIntro:(BOOL)animated {
    
//    [UIView animateWithDuration:0.3 animations:^{
//       
//        _label.alpha = 0;
//        _facebook.alpha = 0;
//        _back.alpha = 0;
//    } completion:^(BOOL finished) {
        [_label removeFromSuperview];
        [_back removeFromSuperview];
        [_facebook removeFromSuperview];
//    }];
    
    _welcome = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    _welcome.center = CGPointMake(160, self.view.frame.size.height / 2);
    _welcome.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
    _welcome.textColor = [UIColor colorWithRed:255/255.0 green:135/255.0 blue:60/255.0 alpha:1];
    _welcome.alpha = 0;
    _welcome.text = @"Welcome to Beak";
    _welcome.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_welcome];
    
    _desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 60)];
    _desc.center = CGPointMake(160, 155);
    _desc.numberOfLines = 0;
    _desc.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _desc.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
    _desc.alpha = 0;
    _desc.text = @"The easiest way to create and interact with iBeacon networks.";
    _desc.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_desc];
    
    _whatBeacons = [UIButton buttonWithType:UIButtonTypeCustom];
    _whatBeacons.alpha = 0;
    _whatBeacons.frame = CGRectMake(0, 180, 320, 44);
    [_whatBeacons setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_whatBeacons.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    [_whatBeacons setTitle:@"What is an iBeacon?" forState:UIControlStateNormal];
    [self.view addSubview:_whatBeacons];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(20, 245, 280, 1)];
    _line.alpha = 0;
    _line.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    [self.view addSubview:_line];
    
    _question = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    _question.center = CGPointMake(160, 290);
    _question.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    _question.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
    _question.alpha = 0;
    _question.text = @"Which option describes you best?";
    _question.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_question];
    
    _haveBeacons = [UIButton buttonWithType:UIButtonTypeCustom];
    _haveBeacons.alpha = 0;
    _haveBeacons.tag = 0;
    [_haveBeacons addTarget:self action:@selector(loginStepWithOptionIndex:) forControlEvents:UIControlEventTouchUpInside];
    _haveBeacons.frame = CGRectMake(10, 340, 300, 44);
    [_haveBeacons setBackgroundColor:[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1]];
    [_haveBeacons setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_haveBeacons setTitle:@"I have beacons" forState:UIControlStateNormal];
    [_haveBeacons.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [self.view addSubview:_haveBeacons];
    
    _joinGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    _joinGroup.alpha = 0;
    _joinGroup.tag = 1;
    [_joinGroup addTarget:self action:@selector(loginStepWithOptionIndex:) forControlEvents:UIControlEventTouchUpInside];
    _joinGroup.frame = CGRectMake(10, 420, 300, 44);
    [_joinGroup setBackgroundColor:[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1]];
    [_joinGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_joinGroup setTitle:@"I want to join a group" forState:UIControlStateNormal];
    [_joinGroup.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [self.view addSubview:_joinGroup];
    
    if (animated) {
        [UIView animateWithDuration:1 animations:^{
            
            _welcome.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.75 animations:^{
                
                _welcome.center = CGPointMake(160, 100);
                
            }];
            
            [UIView animateWithDuration:1 animations:^{
                
                _desc.alpha = 1;
                _question.alpha = 1;
                _whatBeacons.alpha = 1;
                _line.alpha = 1;
                _joinGroup.alpha = 1;
                _haveBeacons.alpha = 1;
                
            }];
            
        }];
    }
    else {
        
        _welcome.alpha = 1;
        _welcome.center = CGPointMake(160, 100);
        _desc.alpha = 1;
        _question.alpha = 1;
        _whatBeacons.alpha = 1;
        _line.alpha = 1;
        _joinGroup.alpha = 1;
        _haveBeacons.alpha = 1;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self showIntro:YES];
}

- (void)goBack {
    
    [self showIntro:NO];
}

- (void)loginStepWithOptionIndex:(UIButton*)sender {
    
    NSInteger index = sender.tag;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (index == 0) {
        
        [def removeObjectForKey:@"joinGroup"];
        [def setObject:@(YES) forKey:@"hasBeacons"];
        [def synchronize];
    }
    else {
        
        [def removeObjectForKey:@"hasBeacons"];
        [def setObject:@(YES) forKey:@"joinGroup"];
        [def synchronize];
    }
    
    _back = [UIButton buttonWithType:UIButtonTypeCustom];
    [_back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    _back.frame = CGRectMake(10, 30, 44, 44);
    _back.alpha = 0;
    [_back setTitle:@"Back" forState:UIControlStateNormal];
    [_back.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18]];
    [_back setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_back];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(30, 200, 260, 80)];
    //    label.center = CGPointMake(160, 155);
    _label.numberOfLines = 0;
    _label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18];
    _label.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
    _label.alpha = 0;
    if (index == 0) {
        _label.text = @"Your on your way to getting your first iBeacon network set up!  But first...";
    }
    else {
        _label.text = @"One last thing.  Let's make you an account!";
    }
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    _facebook = [UIButton buttonWithType:UIButtonTypeCustom];
    _facebook.alpha = 0;
    _facebook.frame = CGRectMake(10, 300, 300, 44);
    [_facebook setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1]];
    [_facebook setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_facebook setTitle:@"Login With Facebook" forState:UIControlStateNormal];
    [_facebook.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [_facebook addTarget:self action:@selector(loginFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_facebook];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _welcome.alpha = 0;
        _desc.alpha = 0;
        _question.alpha = 0;
        _whatBeacons.alpha = 0;
        _line.alpha = 0;
        _joinGroup.alpha = 0;
        _haveBeacons.alpha = 0;
        
        _label.alpha = 1;
        _facebook.alpha = 1;
        _back.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [_welcome removeFromSuperview];
        [_desc removeFromSuperview];
        [_question removeFromSuperview];
        [_whatBeacons removeFromSuperview];
        [_line removeFromSuperview];
        [_joinGroup removeFromSuperview];
        [_haveBeacons removeFromSuperview];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginFacebook {
    
    [_facebook setEnabled:NO];
    
    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
        
        if (error || !user) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Login error!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [_facebook setEnabled:YES];
        }
        if (!user) {
            
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
        } else {
            
            NSLog(@"User logged in through Facebook!");
            
            [self userLoggedIn];
        }
        
    }];

}

- (void)userLoggedIn {
    
    AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"myViewDeckViewController"];
    del.window.rootViewController = controller;
}

//
//- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
//{
//    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"myViewDeckViewController"];
//    self.view.window.rootViewController = controller;
//    NSLog(@"user logged in");
//    NSLog(@"%@", [PFUser currentUser]);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
