//
//  AddMessageViewController.m
//  Beak
//
//  Created by Josh Stern on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "AddMessageViewController.h"

#import "MessageCell.h"

static NSString *kTextCell = @"TextCell";
static NSString *kPhotoCell = @"PhotoCell";


@interface AddMessageViewController () {
    
    UITextView *activeView;
    
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, assign) NSInteger messageCount;
@property (nonatomic, strong) NSMutableArray *textViews;
@property (nonatomic, strong) NSMutableArray *images;

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
    
    _beaconObj[@"messageCount"] = @(_messages.count);
    
    [[[BeaconManager sharedManager] currentMessages] setObject:_messages forKey:[NSString stringWithFormat:@"%@%@", _beaconObj[@"minor"], _beaconObj[@"major"]]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addMessage {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"What data type?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text", @"Image", nil];
    
    action.tag = 1;
    
    [action showInView:self.view];
}

- (void)addTextContent {
    
    PFObject *message = [[PFObject alloc] initWithClassName:@"Message"];
    message[@"type"] = @"text";
    
    [_messages addObject:message];
    [_textViews addObject:[NSNull null]];
    [_images addObject:[NSNull null]];
    
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:_messages.count - 1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    PFObject *message = [[PFObject alloc] initWithClassName:@"Message"];
    message[@"type"] = @"image";
    
    
    
    UIImage *image = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.6);
    
    
    PFFile *file = [PFFile fileWithData:imageData];
    message[@"imageFile"] = file;
    
    [_messages addObject:message];
    [_textViews addObject:[NSNull null]];
    [_images addObject:image];
    
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:_messages.count - 1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)addImageContent {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Add Existing", nil];
    action.tag = 2;
    
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            
            [self addTextContent];
        }
        else if (buttonIndex == 1) {
            
            [self addImageContent];
        }
    }
    else if (actionSheet.tag == 2) {
        
        if (buttonIndex == 0) {
            
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else if (buttonIndex == 1) {
            
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }

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
    
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:kTextCell];
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:kPhotoCell];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMessage)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
    
    _textViews = [[NSMutableArray alloc] init];
    _images = [[NSMutableArray alloc] init];
    
    NSArray *currentMessages = [[BeaconManager sharedManager] currentMessages][[NSString stringWithFormat:@"%@%@", _beaconObj[@"minor"], _beaconObj[@"major"]]];

    if ([_beaconObj[@"messageCount"] intValue] != currentMessages.count) {
     
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query whereKey:@"beacon" equalTo:_beaconObj];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           
            _messages = [objects mutableCopy];
            
            [_tableView reloadData];
            
        }];
        
    }
    else if (currentMessages) {
        
        _messages = [currentMessages mutableCopy];
        
    }
    else {
        
        _messages = [[NSMutableArray alloc] init];
    }
    
    for (int i = 0; i < _messages.count; i ++) {
        
        [_textViews addObject:[NSNull null]];
        [_images addObject:[NSNull null]];
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
    else if (obj[@"type"] && [obj[@"type"] isEqualToString:@"image"]) {
        
        return 70;
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
    NSString *cellID = kTextCell;
    
    PFObject *message = _messages[indexPath.section];
    
    if (message[@"type"] && [message[@"type"] isEqualToString:@"image"]) {
        
        cellID = kPhotoCell;
    }
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];

    if ([cellID isEqualToString:kTextCell]) {
        
        cell.message.delegate = self;
        cell.message.tag = indexPath.section;
        cell.message.text = message[@"body"];
    }
    else {
        
        if ([_images[indexPath.section] isKindOfClass:[UIImage class]]) {
            
            cell.imageThumb.image = _images[indexPath.section];
        }
        else {
            PFFile *theImage = message[@"imageFile"];
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                cell.imageThumb.image = image;
            }];
        }
        
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(MessageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (NSLocationInRange(indexPath.section, NSMakeRange(0, _messages.count))) {
        
        PFObject *obj = _messages[indexPath.section];
        
        if (obj[@"type"] && [obj[@"type"] isEqualToString:@"text"]) {
            obj[@"body"] = cell.message.text;
        }
    }
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
