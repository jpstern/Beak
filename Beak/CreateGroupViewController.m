//
//  CreateGroupViewController.m
//  Beak
//
//  Created by Girish Hari on 3/17/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "CreateGroupViewController.h"

@interface CreateGroupViewController ()


@end

@implementation CreateGroupViewController

//@synthesize groupNameInput;
//@synthesize saveButton;


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
    
    
    UITextField *enterGroupName =[[UITextField alloc] initWithFrame:CGRectMake(20, 80, 280, 40)];
    enterGroupName.borderStyle=UITextBorderStyleRoundedRect;
    enterGroupName.placeholder=@"Enter group name here";
    [self.view addSubview:enterGroupName];
    
    UITableView *beaconTable=[[UITableView alloc] initWithFrame:CGRectMake(20, 170, 280, 280)];

    [self.view addSubview:beaconTable];
    
    
    self.beaconsList=[[NSMutableArray alloc]init];
    [[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *beacons, NSError *error) {
       
        self.beaconsList = beacons;
        
        [self.beaconTable reloadData];
        
    }];
    
    //[beaconsList addObject:@"beacon 1"];
    
    
    
    
    /*if(groupNameInput.text.length>0)
    {
        saveButton.enabled=YES;
    }
    else
    {
        saveButton.enabled=NO;
    }*/
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (IBAction)quitButtonClicked:(id)sender {
    NSLog(@"quitclicked");
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

/*- (IBAction)saveButtonClicked:(id)sender {
    
    //if(groupNameInput.text.length>0)
    //{
     
        //[[BeaconManager sharedManager]saveNewGroup:<#(NSDictionary *)#> withBeacons:<#(NSArray *)#>
        // {
             
             
        // }];
        //groupName.text=groupNameInput.text;
    //}
    
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"Cell";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    ESTBeacon *beacon = self.beaconsList[indexPath.row];
    
    cell.textLabel.text = beacon.proximityUUID.UUIDString;
    
    return cell;
}
@end
