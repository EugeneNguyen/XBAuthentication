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

#define XBAuthenticateService(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/plusauthentication/%@", self.host, X]]]

static XBAuthentication *__sharedAuthentication = nil;

@implementation XBAuthentication
@synthesize password = _password;

+ (XBAuthentication *)sharedInstance
{
    if (!__sharedAuthentication)
    {
        __sharedAuthentication = [[XBAuthentication alloc] init];
    }
    return __sharedAuthentication;
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
        [request setPostValue:self.facebookAccessToken forKey:@"access_token"];
    }
    [request setPostValue:self.md5password forKey:@"password"];
    [request setPostValue:@([self.password length]) forKey:@"password_length"];
    
    if (self.deviceToken)
    {
        [request setPostValue:self.deviceToken forKey:@"device_id"];
        [request setPostValue:@"ios" forKey:@"device_type"];
    }
    
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        NSLog(@"%@", _request.responseString);
        if (!result)
        {
            return;
        }
        
        if ([result[@"code"] intValue] != 200)
        {
            return;
        }
        
        self.token = result[@"token"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignUp:)])
        {
            [self.delegate authenticateDidSignUp:self];
        }
        
        [self pullUserInformation];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@", _request.error);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidFailSignUp:withError:)])
        {
            [self.delegate authenticateDidFailSignUp:self withError:_request.error];
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
    if (self.facebookAccessToken)
    {
        [request setPostValue:self.facebookAccessToken forKey:@"access_token"];
    }
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [request setCompletionBlock:^{
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        NSLog(@"%@", _request.responseString);
        if (!result)
        {
            return;
        }
        
        if ([result[@"code"] intValue] != 200)
        {
            return;
        }
        
        self.token = result[@"token"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidSignIn:)])
        {
            [self.delegate authenticateDidSignIn:self];
        }
        
        [self pullUserInformation];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@", _request.error);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateDidFailSignIn:withError:)])
        {
            [self.delegate authenticateDidFailSignIn:self withError:_request.error];
        }
    }];
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

#pragma mark - User's information

- (void)pullUserInformation
{
    ASIFormDataRequest *request = XBAuthenticateService(@"get_user_information");
    [request setPostValue:self.token forKey:@"token"];
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    
    [request setCompletionBlock:^{
        NSLog(@"%@", _request.responseString);
        NSDictionary *result = [_request.responseString mutableObjectFromJSONString];
        if ([result[@"code"] intValue] != 200)
        {
            return ;
        }
        NSDictionary *data = result[@"data"];
        self.username = data[@"username"];
        self.displayname = data[@"display_name"];
        self.userInformation = data;
    }];
}

#pragma mark - Save / Load session

- (void)saveSession
{
    [[NSUserDefaults standardUserDefaults] setObject:self forKey:@"archived_user_information"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"archived_last_update"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSession
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"archived_last_update"])
    {
        XBAuthentication *authenticator = [[NSUserDefaults standardUserDefaults] objectForKey:@"archived_user_information"];
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"archived_last_update"];
        if (self.expiredTime <= 0 || [[NSDate date] timeIntervalSinceDate:lastUpdate] < self.expiredTime)
        {
            __sharedAuthentication = [authenticator copy];
        }
    }
}

@end
