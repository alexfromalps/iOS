//
//  MBMContactPickerViewController.m
//  ALContactPicker
//
//  Created by Alex  on 10/13/15.
//  Copyright (c) 2015 Alex . All rights reserved.
//

#import "MBMContactPickerViewController.h"
#import "MBMContactPickerSectionHeaderView.h"

@interface MBMContactPickerViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *dataSourceDict;
@property (nonatomic, strong) NSArray      *arrSectionHeaders;

@end

@implementation MBMContactPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _dataSourceDict   = [self prepareDataSourceFromContacts:[self getPhoneContacts]];
    _arrSectionHeaders    = [[_dataSourceDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b){
                          return [a compare:b];
                        }];
    if (_arrSectionHeaders && [_arrSectionHeaders containsObject:@"#"])
    {
        NSMutableArray *sectionsArray = [_arrSectionHeaders mutableCopy];
        [sectionsArray removeObject:@"#"];
        [sectionsArray addObject:@"#"];
        _arrSectionHeaders            = sectionsArray;
        sectionsArray                 = nil;
    }

    [_tableViewContactsList reloadData];
}


// Prepare the the datasouce from the plain conact list
- (NSDictionary *)prepareDataSourceFromContacts:(NSArray *)contacts
{
    NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];
    NSCharacterSet *alphaCharacters = [NSCharacterSet letterCharacterSet];
    
    for (MBMAddressbookContact *contact in contacts)
    {
        @autoreleasepool
        {
            // Special charactor names
            NSString * firstLetter = [[contact.contactDisplayName substringToIndex:1] uppercaseString];
            if (([firstLetter rangeOfCharacterFromSet:alphaCharacters].location == NSNotFound))
            {
                firstLetter = @"#";
            }
            
            if (![dataSource objectForKey:firstLetter] && firstLetter)
            {
                [dataSource setObject:[NSMutableArray array] forKey:firstLetter];
            }
            
            NSMutableArray * arr = [dataSource objectForKey:firstLetter];
            [arr addObject:contact];
        }
    }
    return dataSource;
}


- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSArray *)getPhoneContacts
{
    CFErrorRef *error            = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABRecordRef source           = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef people            = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople              = CFArrayGetCount(people);
    
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
    
    if (people)
    {
        for (int i = 0; i < nPeople; i++)
        {
            @autoreleasepool
            {
                MBMAddressbookContact *contact = [[MBMAddressbookContact alloc] init];
                ABRecordRef person             = CFArrayGetValueAtIndex(people, i);
                
                ABRecordID personId = ABRecordGetRecordID(person);
                
                
                // Get First Name
                CFStringRef firstName = (CFStringRef)ABRecordCopyValue(person,kABPersonFirstNameProperty);
                if (nil != firstName)
                {
                    contact.contactFirstName = [(__bridge NSString*)firstName copy];
                    CFRelease(firstName);
                }
                
                // Last Name
                CFStringRef lastName = (CFStringRef)ABRecordCopyValue(person,kABPersonLastNameProperty);
                if (nil != lastName)
                {
                    contact.contactLastName = [(__bridge NSString*)lastName copy];
                    CFRelease(lastName);
                }
                
                
                contact.contactDisplayName = ([contact.contactFirstName isKindOfClass:[NSString class]] &&
                                              [contact.contactLastName isKindOfClass:[NSString class]]) ?
                                              [NSString stringWithFormat:@"%@ %@",contact.contactFirstName, contact.contactLastName]:
                                              ([contact.contactFirstName isKindOfClass:[NSString class]] ? contact.contactFirstName : contact.contactLastName);
                
                // Phone Numbers
                NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
                ABMultiValueRef multiPhones  = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                for(int i = 0; i<ABMultiValueGetCount(multiPhones); i++)
                {
                    
                    @autoreleasepool
                    {
                        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                        NSString *phoneNumber      = CFBridgingRelease(phoneNumberRef);
                        
                        if (nil != phoneNumber)
                        {
                            [phoneNumbers addObject:phoneNumber];
                        }
                    }
                }
                
                if (nil != multiPhones)
                {
                    CFRelease(multiPhones);
                    contact.contactPhoneNumbers = phoneNumbers;
                    phoneNumbers                = nil;
                }
                
                // Mail Ids
                NSMutableArray *emailIds    = [NSMutableArray new];
                ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
                
                for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++)
                {
                    @autoreleasepool
                    {
                        CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                        NSString *contactEmail      = CFBridgingRelease(contactEmailRef);
                        if (nil != contactEmail)
                        {
                            [emailIds addObject:contactEmail];
                        }
                    }
                }
                
                if ( nil != multiEmails)
                {
                    CFRelease(multiEmails);
                    contact.contactEmailIds = emailIds;
                    emailIds                = nil;
                }
                
                if (nil != items)
                {
                    [items addObject:contact];
                }
            }
        }
    }
    
    CFRelease(people);
    CFRelease(addressBook);
    CFRelease(source);
    
    return items;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrSectionHeaders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    if ([[_dataSourceDict objectForKey:[_arrSectionHeaders objectAtIndex:section]] isKindOfClass:[NSArray class]])
    {
        numberOfRows = [[_dataSourceDict objectForKey:[_arrSectionHeaders objectAtIndex:section]] count];
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MBMContactPickerSectionHeaderView *sectionHeaderView = nil;
    NSDictionary *dict = [NSDictionary dictionary];
    
    NSString *data = [dict objectForKey:nil];
    
    @try
    {
        
        sectionHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MBMContactPickerSectionHeaderView"
                                                                                              owner:nil
                                                                                            options:nil] objectAtIndex:0];
        
        NSArray *arr = [NSArray array];
        [arr objectAtIndex:10];
        [sectionHeaderView setFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
        
        sectionHeaderView.lblSortedSectionHeaderName.text = (_arrSectionHeaders.count > section) ? [_arrSectionHeaders objectAtIndex:section] : @"";
        
        
    }
    @catch (NSException *exception)
    {
        DLog(@"\n---ex---\n %@ Excepion %s \nReason : %@ at Line : %d", exception.name, __PRETTY_FUNCTION__, exception.reason, __LINE__ );
    }
    @finally
    {
        return sectionHeaderView;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell          = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSArray *arr                   = [_dataSourceDict objectForKey:[_arrSectionHeaders objectAtIndex:indexPath.section]];
    MBMAddressbookContact *contact = [arr objectAtIndex:indexPath.row];
    cell.textLabel.text            = contact.contactDisplayName;
    CGRect accessoryViewFrame      = CGRectMake(0.0, 0.0, 20.0, 20.0);
    cell.accessoryView             = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddContactPlusButton"]];
    [cell.accessoryView setFrame:accessoryViewFrame];
    
    cell.selectionStyle         = UITableViewCellSelectionStyleDefault;
    cell.userInteractionEnabled = YES;
    cell.textLabel.enabled      = YES;
    cell.accessoryType          = UITableViewCellAccessoryNone;
    if ([self isAlredayPickedContact:contact])
    {
        cell.accessoryView          = nil;
        cell.accessoryType          = UITableViewCellAccessoryCheckmark;
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled      = NO;
        cell.selectionStyle         = UITableViewCellSelectionStyleNone;
        
    }
    
    return cell;
}


- (BOOL)isAlredayPickedContact:(MBMAddressbookContact *)contactToCheck
{
    BOOL isPickedAlready = NO;
    for (MBMAddressbookContact *contact in _contactsAlreadyPicked)
    {
        @autoreleasepool
        {
            if ([contactToCheck.contactDisplayName isEqualToString:contact.contactDisplayName])
            {
                isPickedAlready = YES;
                break;
            }
        }
    }
    return isPickedAlready;
    
}


#pragma mark - UITableView Delegates


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Parsing the details of the contact at the tapped index
    if ([_arrSectionHeaders count] > indexPath.section &&
        [self.delegate respondsToSelector:@selector(contactPickerViewDidPickContact:)])
    {
        NSString *sectionKey = [_arrSectionHeaders objectAtIndex:indexPath.section];
        NSArray *sectionData = [_dataSourceDict objectForKey:sectionKey];

        if ([sectionData isKindOfClass:[NSArray class]] &&
            [sectionData count] > indexPath.row)
        {
            MBMAddressbookContact *selectedContact = [sectionData objectAtIndex:indexPath.row];
            if (![self isAlredayPickedContact:selectedContact])
            {
                [_delegate contactPickerViewDidPickContact:selectedContact];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                //TODO: Show toast
            }
        }
    }
}



@end
