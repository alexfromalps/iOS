//
//  MBMContact.m
//  ALContactPicker
//
//  Created by Alex  on 10/14/15.
//  Copyright (c) 2015 Alex . All rights reserved.
//

#import "MBMAddressbookContact.h"

@implementation MBMAddressbookContact


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.contactFirstName    forKey:@"contactFirstName"];
    [aCoder encodeObject:self.contactLastName     forKey:@"contactLastName"];
    [aCoder encodeObject:self.contactDisplayName  forKey:@"contactDisplayName"];
    [aCoder encodeObject:self.contactPhoneNumbers forKey:@"contactPhoneNumbers"];
    [aCoder encodeObject:self.contactEmailIds     forKey:@"contactEmailIds"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.contactFirstName    = [aDecoder decodeObjectForKey:@"contactFirstName"];
        self.contactLastName     = [aDecoder decodeObjectForKey:@"contactLastName"];
        self.contactDisplayName  = [aDecoder decodeObjectForKey:@"contactDisplayName"];
        self.contactPhoneNumbers = [aDecoder decodeObjectForKey:@"contactPhoneNumbers"];
        self.contactEmailIds     = [aDecoder decodeObjectForKey:@"contactEmailIds"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBMAddressbookContact *copy = [[self class] allocWithZone:zone];
    copy.contactFirstName       = self.contactFirstName;
    copy.contactLastName        = self.contactLastName;
    copy.contactDisplayName     = self.contactDisplayName;
    copy.contactPhoneNumbers    = self.contactPhoneNumbers;
    copy.contactEmailIds        = self.contactEmailIds;
    return copy;
}

@end
