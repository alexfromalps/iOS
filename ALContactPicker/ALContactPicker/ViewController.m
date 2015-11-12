//
//  ViewController.m
//  ALContactPicker
//
//  Created by Alex  on 10/12/15.
//  Copyright (c) 2015 Alex . All rights reserved.
//

#import "ViewController.h"
#import "MBMContactPickerViewController.h"

@interface ViewController ()
<MBMContactPickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPicker:(id)sender
{
    @try
    {
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                MBMContactPickerViewController *picker = [[MBMContactPickerViewController alloc] initWithNibName:@"MBMContactPickerViewController"
                                                                                          bundle:self.nibBundle];
                picker.delegate                        = self;
                picker.contactsAlreadyPicked           = [self getTheAlreadyPickedContactList];
                [self presentViewController:picker
                                   animated:YES
                                 completion:nil];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:@"Access to the contacts denied"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                                                                     
                                                                 }];
                [alertController addAction:okAction];
                [self presentViewController:alertController
                                   animated:YES
                                 completion:nil];
            }
        });
        
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"\n---ex---\n %@ Excepion %s \nReason : %@ at Line : %d", exception.name, __PRETTY_FUNCTION__, exception.reason, __LINE__ );
    }

}

#pragma mark - Contact Picker view delegate 

- (void)contactPickerViewDidPickContact:(MBMAddressbookContact *)pickedContact
{
    NSMutableArray *pickedContacts = [self getTheAlreadyPickedContactList];
    if (!pickedContacts)
    {
        pickedContacts = [NSMutableArray array];
    }
    [pickedContacts addObject:pickedContact];
    
    [self savePickedContactList:pickedContacts];
    
}

- (NSMutableArray *)getTheAlreadyPickedContactList
{
    NSMutableArray *archivedPickedcontacts = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedContacts"];
    NSMutableArray *pickedContacts = [NSMutableArray arrayWithCapacity:archivedPickedcontacts.count];
    
    for (NSData *archivedContactData in archivedPickedcontacts)
    {
        MBMAddressbookContact *contact = [NSKeyedUnarchiver unarchiveObjectWithData:archivedContactData];
        [pickedContacts addObject:contact];
    }
    
    return pickedContacts;
}

- (void)savePickedContactList:(NSArray *)pickedContactList
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:pickedContactList.count];
    for (MBMAddressbookContact *contact in pickedContactList)
    {
        NSData *encodedContactObject = [NSKeyedArchiver archivedDataWithRootObject:contact];
        [archiveArray addObject:encodedContactObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archiveArray
                                              forKey:@"SavedContacts"];
}


@end
