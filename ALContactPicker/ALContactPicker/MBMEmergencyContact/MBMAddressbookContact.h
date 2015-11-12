//
//  MBMContact.h
//  ALContactPicker
//
//  Created by Alex  on 10/14/15.
//  Copyright (c) 2015 Alex . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBMAddressbookContact : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString * contactFirstName;
@property (nonatomic, copy) NSString * contactLastName;
@property (nonatomic, copy) NSString * contactDisplayName;
@property (nonatomic, copy) NSArray  * contactPhoneNumbers;
@property (nonatomic, copy) NSArray  * contactEmailIds;

@end