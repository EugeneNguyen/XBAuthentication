//
//  XBAViewController.m
//  XBAuthentication
//
//  Created by eugenenguyen on 12/22/2014.
//  Copyright (c) 2014 eugenenguyen. All rights reserved.
//

#import "XBAViewController.h"
#import <XBAuthentication.h>

@interface XBAViewController () <XBAuthenticationDelegate>

@end

@implementation XBAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    XBAuthentication *authenticator = [XBAuthentication sharedInstance];
    authenticator.username = @"eugenenguyen2";
    authenticator.password = @"20081991";
    [authenticator signin];
    
    authenticator.delegate = self;
}

#pragma mark - XBAuthenticate Delegate

- (void)authenticateDidSignIn:(XBAuthentication *)authenticator
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
