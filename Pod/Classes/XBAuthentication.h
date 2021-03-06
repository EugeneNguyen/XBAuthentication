//
//  XBAuthentication.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/22/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XBAuthentication;

@protocol XBAuthenticationDelegate <NSObject>

@optional

- (void)authenticateDidSignIn:(XBAuthentication *)authenticator;
- (void)authenticateDidFailSignIn:(XBAuthentication *)authenticator withError:(NSError *)error andInformation:(NSDictionary *)information;

- (void)authenticateDidSignUp:(XBAuthentication *)authenticator;
- (void)authenticateDidFailSignUp:(XBAuthentication *)authenticator withError:(NSError *)error andInformation:(NSDictionary *)information;

- (void)authenticateDidSignOut:(XBAuthentication *)authenticator;

- (void)authenticateDidRecoverPassword:(XBAuthentication *)authenticator;

- (void)authenticateDidFailRecoverPassword:(XBAuthentication *)authenticator withError:(NSError *)error andInformation:(NSDictionary *)information;

@end

@interface XBAuthentication : NSObject
{
    
}

@property (nonatomic, retain) NSString *host;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password, *md5password;
@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * facebookAccessToken;
@property (nonatomic, retain) NSString * facebookID;

@property (nonatomic, assign) int userid;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString * displayname;
@property (nonatomic, retain) NSString * avatarPath;
@property (nonatomic, retain) UIImage * avatar;

@property (nonatomic, retain) NSDictionary * errorDescription;
@property (nonatomic, retain) NSArray * erroList;


@property (nonatomic, retain) NSDictionary * userInformation;
@property (nonatomic, retain) NSDictionary * config;

@property (nonatomic, assign) long expiredTime; // in second, from the last time app shutdown

@property (nonatomic, assign) id <XBAuthenticationDelegate> delegate;

// save and load the login status in case of you want to save your session

- (void)saveSession;
- (void)loadSession;

- (void)signup;
- (void)signinWithFacebook;
- (void)signin;
- (void)signout;
+ (XBAuthentication *)sharedInstance;
- (void)loadInformationFromPlist:(NSString *)plistName;
- (void)loadDescriptionFromPlist:(NSString *)plistName;

- (void)pullUserInformation;


@end

