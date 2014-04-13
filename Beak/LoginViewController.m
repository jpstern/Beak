//
//  LoginViewController.m
//  Beak
//
//  Created by Neil Sood on 4/13/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "LoginViewController.h"
#import "MyViewDeckViewController.h"

@interface LoginViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    [_fblogin setEnabled:NO];
    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Login error!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [_fblogin setEnabled:YES];
        }
        if (!user) {
            
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
        } else {
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"myViewDeckViewController"];
            self.view.window.rootViewController = controller;
            NSLog(@"User logged in through Facebook!");
        }
        
    }];

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
