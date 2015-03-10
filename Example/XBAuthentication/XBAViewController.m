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
{
    IBOutlet UITextField *tfUsername, *tfPassword;
}

@end

@implementation XBAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)didPressLogin:(id)sender
{
    XBAuthentication *authenticator = [XBAuthentication sharedInstance];
    authenticator.username = tfUsername.text;
    authenticator.password = tfPassword.text;
    [authenticator signin];
    
    authenticator.delegate = self;
}

- (IBAction)didPressLoginWithFacebook:(id)sender
{
    [[XBAuthentication sharedInstance] requestFacebookToken];
}

#pragma mark - XBAuthenticate Delegate

- (void)authenticateDidSignIn:(XBAuthentication *)authenticator
{
    NSLog(@"%@",authenticator.errorDescription);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
