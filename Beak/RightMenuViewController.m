//
//  RightMenuViewController.m
//  Beak
//
//  Created by Josh Stern on 4/1/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "RightMenuViewController.h"

#import "MenuTableViewCell.h"

@interface RightMenuViewController ()

@end

@implementation RightMenuViewController

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
    
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"CellID"];
    self.tableView.scrollEnabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.view.frame.size.height / 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"CellID";
    
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        cell.title.text = @"Create Group";
    }
    else if (indexPath.row == 1) {
        
        cell.title.text = @"Manage Groups";
    }
    else {
        
        cell.title.text = @"History";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"createViewController"];
        
        [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
    
    }
    else if (indexPath.row == 1) {
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"manageViewController"];
        
        [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
        
    }
    else {
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"historyViewController"];
        
        [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
    }
    
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
