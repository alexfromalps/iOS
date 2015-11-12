//
//  MBMContactPickerViewController.h
//  ALContactPicker
//
//  Created by Alex  on 10/13/15.
//  Copyright (c) 2015 Alex . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMAddressbookContact.h"

@import AddressBook;
@import AddressBookUI;


@protocol MBMContactPickerViewControllerDelegate;

@interface MBMContactPickerViewController : UIViewController

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet UIButton    *btnCancel;

@property (nonatomic, weak) IBOutlet UISearchBar *serachBarContactSearch;

@property (nonatomic, weak) IBOutlet UITableView *tableViewContactsList;

#pragma mark - Public Properties

/*!
 *  The list of all contacts already selected.
 */
@property (nonatomic, strong) NSArray * contactsAlreadyPicked;

/*!
 *  Delegate property
 */
@property (nonatomic, strong) id <MBMContactPickerViewControllerDelegate> delegate;


@end

@protocol MBMContactPickerViewControllerDelegate <NSObject>

@required

- (void)contactPickerViewDidPickContact:(MBMAddressbookContact *)pickedContact;

@end