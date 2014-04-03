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
    
    UILabel *beaconTableText=[[UILabel alloc]initWithFrame:CGRectMake(20, 160, 280, 20)];
    beaconTableText.text=@"Beacons Available:";
    [self.view addSubview:beaconTableText];
    
    self.enterGroupName =[[UITextField alloc] initWithFrame:CGRectMake(20, 80, 280, 40)];
    self.enterGroupName.borderStyle=UITextBorderStyleRoundedRect;
    self.enterGroupName.placeholder=@"Enter group name here";
    [self.view addSubview:self.enterGroupName];
    
    UITableView *beaconTable=[[UITableView alloc] initWithFrame:CGRectMake(20, 180, 280, 280)];
    [self.view addSubview:beaconTable];
    
    UIBarButtonItem *saveButton=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(goToSave)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    self.beaconsList=[[NSMutableArray alloc]init];
    [[BeaconManager sharedManager] searchForNearbyBeacons:^(NSArray *beacons, NSError *error) {
       
        NSLog(@"searching..%d",beacons.count);
        self.beaconsList = beacons;
        [self.beaconTable reloadData];
        
    }];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                   target:self action:@selector(goToSave)];
    //[self.view addSubview:infoButton];
    
    //NSLog(@"searching..%d",self.beaconsList.count);


    
    //[self.beaconsList addObject:@"beacon 1",@"beacon2"];
    
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

- (void)goToSave{
    
    NSLog(@"goToSave!");
    if(self.enterGroupName.text.length==0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid group name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //[alert release];
    }
    
    NSLog(self.enterGroupName.text);
    
    //self.enterGroupName
    //if(groupNameInput.text.length>0)
    //{
     
     //   [[[BeaconManager sharedManager]saveNewGroup:<#(NSDictionary *)#> withBeacons:<#(NSArray *)#>]
     //    {
             
            //
     //    }];
        //groupName.text=groupNameInput.text;
    //}
    
}


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
    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 235, 0, 0)];
    [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView=mySwitch;
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    ESTBeacon *beacon = self.beaconsList[indexPath.row];
    
    cell.textLabel.text = beacon.proximityUUID.UUIDString;
    NSNumber *major=beacon.major;
    NSNumber *minor=beacon.minor;
    NSString *temp=[NSString stringWithFormat:@"Major:%@ Minor:%@",major,minor];
    cell.detailTextLabel.text=temp;
    NSLog(temp);
    
    
    return cell;
}


- (void)changeSwitch:(id)sender{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
    }
}
@end
