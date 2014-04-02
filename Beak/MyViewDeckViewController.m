//
//  MyViewDeckViewController.m
//  Beak
//
//  Created by Josh Stern on 4/1/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "MyViewDeckViewController.h"

@interface MyViewDeckViewController ()

@end

@implementation MyViewDeckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setNavigationControllerBehavior:IIViewDeckNavigationControllerIntegrated];
    
    [self setCenterController:[self.storyboard
                               instantiateViewControllerWithIdentifier:@"centerPanel"]];
    
    [self setRightController:[self.storyboard
                              instantiateViewControllerWithIdentifier:@"rightPanel"]];
    
    
    [self setRightSize:180];
    
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
