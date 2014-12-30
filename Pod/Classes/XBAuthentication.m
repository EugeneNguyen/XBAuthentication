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
    [request setPostValue:self.md5password forKey:@"password"];
    [request setPostValue:@([self.password length]) forKey:@"password_length"];
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
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@", _request.error);
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
    }];
    
    [request setFailedBlock:^{
        NSLog(@"%@", _request.error);
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
