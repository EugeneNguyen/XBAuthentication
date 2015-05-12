//
//  XBFBData.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/7/15.
//
//

#import "XBFBData.h"

@implementation XBFBData
@synthesize birthday;
@synthesize email;
@synthesize gender;
@synthesize id;
@synthesize lastname;
@synthesize link;
@synthesize locale;
@synthesize name;
@synthesize timezone;
@synthesize updatedTime;
@synthesize verified;
@synthesize accessTokenData;

- (void)updateWithInfo:(NSDictionary *)info
{
    if (info[@"birthday"]) self.birthday = info[@"birthday"];
    if (info[@"email"]) self.email = info[@"email"];
    if (info[@"first_name"]) self.firstname = info[@"first_name"];
    if (info[@"gender"]) self.gender = info[@"gender"];
    if (info[@"id"]) self.id = info[@"id"];
    if (info[@"last_name"]) self.lastname = info[@"last_name"];
    if (info[@"link"]) self.link = info[@"link"];
    if (info[@"locale"]) self.locale = info[@"locale"];
    if (info[@"name"]) self.name = info[@"name"];
    if (info[@"timezone"]) self.timezone = info[@"timezone"];
    if (info[@"updated_time"]) self.updatedTime = info[@"updated_time"];
    if (info[@"verified"]) self.updatedTime = info[@"verified"];
}

@end
