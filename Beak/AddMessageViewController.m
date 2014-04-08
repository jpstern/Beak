//
//  AddMessageViewController.m
//  Beak
//
//  Created by Josh Stern on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "AddMessageViewController.h"

#import "MessageCell.h"

@interface AddMessageViewController () {
    
    UITextView *activeView;
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, assign) NSInteger messageCount;
@property (nonatomic, strong) NSMutableArray *textViews;

@end

@implementation AddMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismissView {
    
    [activeView resignFirstResponder];
    
    [[[BeaconManager sharedManager] currentMessages] setObject:_messages forKey:[NSString stringWithFormat:@"%@%@", _beaconObj[@"minor"], _beaconObj[@"major"]]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addMessage {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"What data type?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text", @"Image", nil];
    
    [action showInView:self.view];
}

- (void)addTextContent {
    
    PFObject *message = [[PFObject alloc] initWithClassName:@"Message"];
    message[@"type"] = @"text";
    
    [_messages addObject:message];
    [_textViews addObject:[NSNull null]];
    
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:_messages.count - 1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self addTextContent];
    }
    else if (buttonIndex == 1) {
        
        
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    activeView = textView;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:textView.tag];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64, 0.0, 220, 0.0);
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    PFObject *obj = _messages[textView.tag];
    obj[@"body"] = textView.text;
    
    activeView = nil;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:textView.tag];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0.0);
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:@"CellID"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMessage)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
    
    _textViews = [[NSMutableArray alloc] init];
    
    NSArray *currentMessages = [[BeaconManager sharedManager] currentMessages][[NSString stringWithFormat:@"%@%@", _beaconObj[@"minor"], _beaconObj[@"major"]]];
    
    if (currentMessages) {
        
        _messages = [currentMessages mutableCopy];
        
    }
    else {
        
        _messages = [[NSMutableArray alloc] init];
    }
    
    for (int i = 0; i < _messages.count; i ++) {
        
        [_textViews addObject:[NSNull null]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *obj = _messages[indexPath.section];
    
    if (obj[@"type"] && [obj[@"type"] isEqualToString:@"text"]) {
        
        return 150;
    }
    
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _messages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];

    cell.message.delegate = self;
    cell.message.tag = indexPath.section;
    cell.message.text = _messages[indexPath.row][@"body"];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(MessageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *obj = _messages[indexPath.section];
    obj[@"body"] = cell.message.text;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *message = _messages[indexPath.section];
    
    [message deleteInBackground];
    [_messages removeObject:message];
    
    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
