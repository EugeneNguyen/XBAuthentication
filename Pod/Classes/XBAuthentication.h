//
//  XBAuthentication.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/22/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XBFBData.h"

typedef void (^XBARequestCompletion)(NSString * responseString, id object, int errorCode, NSString *description, NSError * error);

@class XBAuthentication;

@protocol XBAuthenticationDelegate <NSObject>

@optional

- (void)authenticateDidSignIn:(XBAuthentication *)authenticator;
- (void)authenticateDidFailSignIn:(XBAuthentication *)authenticator withError:(NSError *)error andInformation:(NSDictionary *)information;

- (void)authenticateDidSignUp:(XBAuthentication *)authenticator;
- (void)authenticateDidFailSignUp:(XBAuthentication *)authenticator withError:(NSError *)error andInformation:(NSDictionary *)information;

- (void)authenticateDidSignOut:(XBAuthentication *)authenticator;

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
@property (nonatomic, retain) NSString * facebookAppID;

@property (nonatomic, assign) int userid;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString * displayname;
@property (nonatomic, retain) NSString * avatarPath;
@property (nonatomic, retain) UIImage * avatar;

@property (nonatomic, retain) NSDictionary * errorDescription;
@property (nonatomic, retain) NSArray * erroList;
@property (nonatomic, assign) BOOL isDebug;

@property (nonatomic, retain) NSDictionary * userInformation;
@property (nonatomic, retain) NSDictionary * config;

@property (nonatomic, retain) XBFBData *facebook;

@property (nonatomic, assign) long expiredTime; // in second, from the last time app shutdown

@property (nonatomic, assign) id <XBAuthenticationDelegate> delegate;

// save and load the login status in case of you want to save your session

+ (XBAuthentication *)sharedInstance;

#pragma mark - Handle event from UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)saveSession;
- (void)loadSessionWithCompletion:(XBARequestCompletion)completion;

- (void)signupWithCompletion:(XBARequestCompletion)completion;
- (void)signinWithFacebookAndCompletion:(XBARequestCompletion)completion;
- (void)signinWithCompletion:(XBARequestCompletion)completion;
- (void)signout;

- (void)signoutFacebook;
- (void)startLoginFacebookWithCompletion:(XBARequestCompletion)completion;

- (void)loadInformationFromPlist:(NSString *)plistName;
- (void)loadDescriptionFromPlist:(NSString *)plistName;

- (void)pullUserInformationWithCompletion:(XBARequestCompletion)completion;

- (void)forgotPasswordForUser:(NSString *)user complete:(XBARequestCompletion)completion;
- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword complete:(XBARequestCompletion)completion;

@end

