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
#import "FacebookSDK.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#define XBAuthenticateService(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/plusauthentication/%@", self.host, X]]]

static int ddLogLevel;

static XBAuthentication *__sharedAuthentication = nil;

@implementation XBAuthentication
@synthesize password = _password;
@synthesize isDebug = _isDebug;

+ (XBAuthentication *)sharedInstance
{
    if (!__sharedAuthentication)
    {
        __sharedAuthentication = [[XBAuthentication alloc] init];
    }
    return __sharedAuthentication;
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

- (void)signup
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
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        DDLogInfo(@"%@", _request.responseString);
        if (!result)
        {
            return;
        }
        
        if ([result[@"code"] intValue] != 200)
        {
            [self.delegate authenticateDidFailSignUp:self withError:nil andInformation:result];
            return;
        }
        
        self.errorDescription = [_request.responseString objectFromJSONString];
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignUp:)])
        {
            [self.delegate authenticateDidSignUp:self];
        }
        if ([result[@"code"] intValue] == 200)
        {
            self.token = result[@"token"];
            [self pullUserInformation];
        }
    }];
    
    [request setFailedBlock:^{
        DDLogInfo(@"%@", _request.error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidFailSignUp:withError:andInformation:)])
        {
            [self.delegate authenticateDidFailSignUp:self withError:_request.error andInformation:nil];
        }
    }];
}

- (void)signin
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
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        DDLogInfo(@"%@", _request.responseString);
        if (!result)
        {
            return;
        }
        
        if ([result[@"code"] intValue] != 200)
        {
            [self.delegate authenticateDidFailSignIn:self withError:nil andInformation:result];
            return;
        }
        
        self.errorDescription = [_request.responseString objectFromJSONString];
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignIn:)])
        {
            [self.delegate authenticateDidSignIn:self];
        }
        if ([result[@"code"] intValue] == 200)
        {
            self.token = result[@"token"];
            [self pullUserInformation];
        }
    }];
    
    [request setFailedBlock:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidFailSignIn:withError:andInformation:)])
        {
            [self.delegate authenticateDidFailSignIn:self withError:_request.error andInformation:nil];
        }
    }];
}

- (void)signinWithFacebook
{
    ASIFormDataRequest *request = XBAuthenticateService(@"login");
    if (self.facebookID)
    {
        [request setPostValue:self.facebookID forKey:@"facebook_id"];
    }
    if (self.facebookAccessToken)
    {
        [request setPostValue:self.facebookAccessToken forKey:@"facebook_access_token"];
    }
    if (self.deviceToken)
    {
        [request setPostValue:self.deviceToken forKey:@"device_id"];
        [request setPostValue:@"ios" forKey:@"device_type"];
    }
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        DDLogInfo(@"%@", _request.responseString);
        if (!result)
        {
            return;
        }
        
        self.errorDescription = [_request.responseString objectFromJSONString];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignIn:)])
        {
            [self.delegate authenticateDidSignIn:self];
        }
        
        if ([result[@"code"] intValue] == 200)
        {
            self.token = result[@"token"];
            [self pullUserInformation];
        }
    }];
    
    [request setFailedBlock:^{
        DDLogInfo(@"%@", _request.error);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidFailSignIn:withError:andInformation:)])
        {
            [self.delegate authenticateDidFailSignIn:self withError:_request.error andInformation:nil];
        }
    }];
}

- (void)requestFacebookToken
{
    [FBSettings setDefaultAppID:self.facebookAppID];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *sessison, FBSessionState state, NSError *error) {
                                          [self requestFacebookInformtion];
                                      }];
    }
    else
    {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error)
         {
             [self requestFacebookInformtion];
         }];
    }
}

- (void)requestFacebookInformtion
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        DDLogInfo(@"%@", result);
        self.facebookID = [result objectForKey:@"id"];
        [self signinWithFacebook];
    }];
}

- (void)signoutFacebook
{
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
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
        DDLogInfo(@"%@", request.error);
        completion(nil, request.error);
    }];
    [_request setCompletionBlock:^{
        DDLogInfo(@"%@", request.responseString);
        completion(request.responseString, nil);
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
        DDLogInfo(@"%@", request.error);
        completion(nil, request.error);
    }];
    [_request setCompletionBlock:^{
        completion(request.responseString, nil);
        DDLogInfo(@"%@", request.responseString);
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
        DDLogInfo(@"%@", _request.responseString);
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        if ([result[@"code"] intValue] != 200)
        {
            return ;
        }
        NSDictionary *data = result[@"data"];
        self.username = data[@"username"];
        self.displayname = data[@"display_name"];
        self.userInformation = data;
        [self saveSession];
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
