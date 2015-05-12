//
//  XBFBData.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/7/15.
//
//

#import <Foundation/Foundation.h>
#import "FBSDKCoreKit.h"
#import "FBSDKLoginKit.h"

@interface XBFBData : NSObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * updatedTime;
@property (nonatomic, retain) NSString * verified;
@property (nonatomic, retain) NSString * name;

@property (nonatomic, retain) FBSDKAccessToken *accessTokenData;

- (void)updateWithInfo:(NSDictionary *)info;

@end
