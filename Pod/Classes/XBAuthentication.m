//
//  XBAuthentication.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/22/14.
//
//

#import "XBAuthentication.h"
#import "ASIFormDataRequest.h"
#import "NSString+MD5.h"
#import "JSONKit.h"
#import "SDImageCache.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#define XBAuthenticateService(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/plusauthentication/%@", self.host, X]]]

@interface XBAuthentication ()
{
    XBARequestCompletion completionBlock;
}

@end

static int ddLogLevel;

static XBAuthentication *__sharedAuthentication = nil;

@implementation XBAuthentication
@synthesize password = _password;
@synthesize isDebug = _isDebug;
@synthesize facebook;

+ (XBAuthentication *)sharedInstance
{
    if (!__sharedAuthentication)
    {
        __sharedAuthentication = [[XBAuthentication alloc] init];
        __sharedAuthentication.facebook = [[XBFBData alloc] init];
    }
    return __sharedAuthentication;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (!dictionary[@"FacebookAppID"])
    {
        NSLog(@"Please setup FacebookAppID in Plist");
    }
    if (!dictionary[@"FacebookDisplayName"])
    {
        NSLog(@"Please setup FacebookDisplayName in Plist");
    }
    if (dictionary[@"FacebookAppID"])
    {
        BOOL found = NO;
        NSString *appID = [NSString stringWithFormat:@"fb%@", dictionary[@"FacebookAppID"]];
        if (dictionary[@"CFBundleURLTypes"])
        {
            for (NSDictionary *item in dictionary[@"CFBundleURLTypes"])
            {
                if (item[@"CFBundleURLSchemes"])
                {
                    for (NSString *scheme in item[@"CFBundleURLSchemes"])
                    {
                        if ([scheme isEqualToString:appID])
                        {
                            found = YES;
                            break;
                        }
                    }
                }
            }
        }
        if (!found)
        {
            NSLog(@"Please setup URL types in Plist as %@", appID);
        }
        
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)setIsDebug:(BOOL)isDebug
{
    _isDebug = isDebug;
    if (isDebug)
    {
//        ddLogLevel = DDLogLevelVerbose;
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    else
    {
//        ddLogLevel = DDLogLevelError;
    }
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    self.md5password = [_password MD5Digest];
}

#pragma mark - Sign up/in/out

- (void)signupWithCompletion:(XBARequestCompletion)completion
{
    ASIFormDataRequest *request = XBAuthenticateService(@"register");
    if (self.username)
    {
        [request setPostValue:self.username forKey:@"username"];
    }
    if (self.email)
    {
        [request setPostValue:self.email forKey:@"email"];
    }
    if (self.displayname)
    {
        [request setPostValue:self.displayname forKey:@"displayname"];
    }
    if (self.facebookAccessToken)
    {
        [request setPostValue:self.facebookAccessToken forKey:@"facebook_access_token"];
    }
    if (self.facebookID)
    {
        [request setPostValue:self.facebookID forKey:@"facebook_id"];
    }
    [request setPostValue:self.md5password forKey:@"password"];
    [request setPostValue:@([self.password length]) forKey:@"password_length"];
    
    if (self.deviceToken)
    {
        [request setPostValue:self.deviceToken forKey:@"device_id"];
        [request setPostValue:@"ios" forKey:@"device_type"];
    }
    
    if (self.userInformation)
    {
        [request setPostValue:[self.userInformation JSONString] forKey:@"extra_fields"];
    }
    
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [_request setFailedBlock:^{
        completion(nil, nil, -1, nil, request.error);
    }];
    
    [_request setCompletionBlock:^{
        NSDictionary *json = [request.responseString objectFromJSONString];
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
        if ([json[@"code"] intValue] == 200)
        {
            self.token = json[@"token"];
            [self pullUserInformation];
        }
    }];
}

- (void)signinWithCompletion:(XBARequestCompletion)completion
{
    ASIFormDataRequest *request = XBAuthenticateService(@"login");
    if (self.username)
    {
        [request setPostValue:self.username forKey:@"username"];
    }
    if (self.email)
    {
        [request setPostValue:self.email forKey:@"email"];
    }
    [request setPostValue:self.md5password forKey:@"password"];
    if (self.deviceToken)
    {
        [request setPostValue:self.deviceToken forKey:@"device_id"];
        [request setPostValue:@"ios" forKey:@"device_type"];
    }
    if (self.facebookID)
    {
        [request setPostValue:self.facebookID forKey:@"facebook_id"];
    }
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [_request setFailedBlock:^{
        completion(nil, nil, -1, nil, request.error);
    }];
    
    [_request setCompletionBlock:^{
        NSDictionary *json = [request.responseString objectFromJSONString];
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
        if ([json[@"code"] intValue] == 200)
        {
            self.token = json[@"token"];
            [self pullUserInformation];
        }
    }];
}

- (void)signinWithFacebookAndCompletion:(XBARequestCompletion)completion
{
    ASIFormDataRequest *request = XBAuthenticateService(@"login");
    if (self.facebook.accessTokenData.userID)
    {
        [request setPostValue:self.facebook.accessTokenData.userID forKey:@"facebook_id"];
    }
    if (self.facebook.accessTokenData.tokenString)
    {
        [request setPostValue:self.facebook.accessTokenData.tokenString forKey:@"facebook_access_token"];
    }
    if (self.deviceToken)
    {
        [request setPostValue:self.deviceToken forKey:@"device_id"];
        [request setPostValue:@"ios" forKey:@"device_type"];
    }
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [_request setFailedBlock:^{
        completion(nil, nil, -1, request.error.localizedDescription, request.error);
    }];
    
    [_request setCompletionBlock:^{
        NSDictionary *json = [request.responseString objectFromJSONString];
        if ([json[@"code"] intValue] == 200)
        {
            self.token = json[@"token"];
            [self pullUserInformation];
        }
    }];
}

- (void)startLoginFacebookWithCompletion:(XBARequestCompletion)completion
{
    completionBlock = completion;
    if ([FBSDKAccessToken currentAccessToken]) {
        [self requestFacebookInformtion];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error)
            {
                completionBlock(nil, nil, -1, error.localizedDescription, error);
            }
            else if (result.isCancelled)
            {
                completionBlock(nil, nil, -1, @"Authorization Failed", nil);
            }
            else
            {
                [self requestFacebookInformtion];
            }
        }];
    }
}

- (void)requestFacebookInformtion
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (error)
         {
             completionBlock(nil, nil, -1, error.localizedDescription, error);
             return;
         }
         self.facebook.accessTokenData = [FBSDKAccessToken currentAccessToken];;
         [self.facebook updateWithInfo:result];
         [self signinWithFacebookAndCompletion:completionBlock];
     }];
}

- (void)signoutFacebook
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
    }
}

- (void)signout
{
    ASIFormDataRequest *request = XBAuthenticateService(@"login");
    [request setPostValue:self.token forKey:@"token"];
    [request startAsynchronous];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignOut:)])
    {
        [self.delegate authenticateDidSignOut:self];
    }
    __sharedAuthentication = nil;
}

- (void)loadInformationFromPlist:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    self.config = [NSDictionary dictionaryWithContentsOfFile:path];
}

- (void)loadDescriptionFromPlist:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    self.erroList = [NSArray arrayWithContentsOfFile:path];
}

- (void)forgotPasswordForUser:(NSString *)user complete:(XBARequestCompletion)completion
{
    ASIFormDataRequest *request = XBAuthenticateService(@"forgot_password_generate_code");
    [request setPostValue:user forKey:@"email"];
    
    __block ASIFormDataRequest *_request = request;
    [_request setFailedBlock:^{
        completion(nil, nil, -1, nil, request.error);
    }];
    [_request setCompletionBlock:^{
        NSDictionary *json = [request.responseString objectFromJSONString];
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
    }];
    [request startAsynchronous];
}

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword complete:(XBARequestCompletion)completion
{
    ASIFormDataRequest *request = XBAuthenticateService(@"change_password");
    [request setPostValue:self.token forKey:@"token"];
    [request setPostValue:[oldPassword MD5Digest] forKey:@"oldpassword"];
    [request setPostValue:[newPassword MD5Digest] forKey:@"newpassword"];
    
    __block ASIFormDataRequest *_request = request;
    [_request setFailedBlock:^{
        completion(nil, nil, -1, nil, request.error);
    }];
    [_request setCompletionBlock:^{
        NSDictionary *json = [request.responseString objectFromJSONString];
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
    }];
    [request startAsynchronous];
}

#pragma mark - User's information

- (void)pullUserInformation
{
    ASIFormDataRequest *request = XBAuthenticateService(@"get_user_information");
    [request setPostValue:self.token forKey:@"token"];
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        if ([result[@"code"] intValue] != 200)
        {
            return ;
        }
        NSDictionary *data = result[@"data"];
        self.username = data[@"username"];
        self.displayname = data[@"display_name"];
        self.userid = [data[@"id"] intValue];
        self.userInformation = data;
        [self saveSession];
        if (completionBlock)
        {
            completionBlock(_request.responseString, data, [result[@"code"] intValue], result[@"description"], nil);
        }
    }];
}

#pragma mark - Save / Load session

- (void)saveSession
{
    if (self.token)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"archived_user_information"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"archived_last_update"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)loadSession
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"archived_last_update"])
    {
        self.token = [[NSUserDefaults standardUserDefaults] objectForKey:@"archived_user_information"];
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"archived_last_update"];
        if (self.expiredTime <= 0 || [[NSDate date] timeIntervalSinceDate:lastUpdate] < self.expiredTime)
        {
            [self pullUserInformation];
        }
    }
}


@end
