//
//  XBAuthentication.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/22/14.
//
//

#import "XBAuthentication.h"
#import "NSString+MD5.h"
#import "JSONKit.h"
#import "SDImageCache.h"
#import "XBCacheRequest.h"

@interface XBAuthentication ()
{
    XBARequestCompletion completionBlock;
}

@end

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

- (void)setPassword:(NSString *)password
{
    _password = password;
    self.md5password = [_password MD5Digest];
}

#pragma mark - Sign up/in/out

- (void)signupWithCompletion:(XBARequestCompletion)completion
{
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/register");
    request.disableCache = YES;
    if (self.username)
    {
        request.dataPost[@"username"] = self.username;
    }
    if (self.email)
    {
        request.dataPost[@"email"] = self.email;
    }
    if (self.displayname)
    {
        request.dataPost[@"displayname"] = self.displayname;
    }
    if (self.facebookAccessToken)
    {
        request.dataPost[@"facebook_access_token"] = self.facebookAccessToken;
    }
    if (self.facebookID)
    {
        request.dataPost[@"facebook_id"] = self.facebookID;
    }
    request.dataPost[@"password"] = self.md5password;
    request.dataPost[@"password_length"] = @([self.password length]);
    
    if (self.deviceToken)
    {
        request.dataPost[@"device_id"] = self.deviceToken;
        request.dataPost[@"device_type"] = @"ios";
    }
    
    if (self.userInformation)
    {
        request.dataPost[@"extra_fields"] = [self.userInformation JSONString];
    }
    
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        if (error)
        {
            completion(nil, nil, -1, nil, error);
            return;
        }
        completion(request.responseString, object, [object[@"code"] intValue], object[@"description"], nil);
        if ([object[@"code"] intValue] == 200)
        {
            self.token = object[@"token"];
            [self pullUserInformation];
        }
    }];
}

- (void)signinWithCompletion:(XBARequestCompletion)completion
{
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/login");
    request.disableCache = YES;
    if (self.username)
    {
        request.dataPost[@"username"] = self.username;
    }
    if (self.email)
    {
        request.dataPost[@"email"] = self.email;
    }
    request.dataPost[@"password"] = self.md5password;
    if (self.deviceToken)
    {
        request.dataPost[@"device_id"] = self.deviceToken;
        request.dataPost[@"device_type"] = @"ios";
    }
    if (self.facebookID)
    {
        request.dataPost[@"facebook_id"] = self.facebookID;
    }
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id json) {
        if (error)
        {
            completion(nil, nil, -1, nil, error);
            return;
        }
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
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/login");
    request.disableCache = YES;
    if (self.facebook.accessTokenData.userID)
    {
        request.dataPost[@"facebook_id"] = self.facebook.accessTokenData.userID;
    }
    if (self.facebook.accessTokenData.tokenString)
    {
        request.dataPost[@"facebook_access_token"] = self.facebook.accessTokenData.tokenString;
    }
    if (self.deviceToken)
    {
        request.dataPost[@"device_id"] = self.deviceToken;
        request.dataPost[@"device_type"] = @"ios";
    }
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id json) {
        if (error)
        {
            completion(nil, nil, -1, error.localizedDescription, error);
            return;
        }
        if ([json[@"code"] intValue] == 200)
        {
            self.token = json[@"token"];
            [self pullUserInformation];
        }
    }];
}

- (void)startLoginFacebookWithCompletion:(XBARequestCompletion)completion
{
    [FBSDKSettings setAppID:self.facebookAppID];
    completionBlock = completion;
    if ([FBSDKAccessToken currentAccessToken]) {
        [self requestFacebookInformtion];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
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
    __sharedAuthentication = nil;
}

- (void)signout
{
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/login");
    request.disableCache = YES;
    request.dataPost[@"token"] = self.token;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        
    }];
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
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/forgot_password_generate_code");
    request.disableCache = YES;
    request.dataPost[@"email"] = user;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id json) {
        if (error)
        {
            completion(nil, nil, -1, nil, error);
            return;
        }
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
    }];
}

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword complete:(XBARequestCompletion)completion
{
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/change_password");
    request.disableCache = YES;
    request.dataPost[@"token"] = self.token;
    request.dataPost[@"oldpassword"] = [oldPassword MD5Digest];
    request.dataPost[@"newpassword"] = [newPassword MD5Digest];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id json) {
        if (error)
        {
            completion(nil, nil, -1, nil, error);
            return;
        }
        completion(request.responseString, json, [json[@"code"] intValue], json[@"description"], nil);
    }];
}

#pragma mark - User's information

- (void)pullUserInformation
{
    XBCacheRequest * request = XBCacheRequest(@"plusauthentication/get_user_information");
    request.disableCache = YES;
    request.dataPost[@"token"] = self.token;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *resultString, BOOL fromCache, NSError *error, id result) {
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
            completionBlock(request.responseString, data, [result[@"code"] intValue], result[@"description"], nil);
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
