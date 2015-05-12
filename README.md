# XBAuthentication

[![CI Status](http://img.shields.io/travis/eugenenguyen/XBAuthentication.svg?style=flat)](https://travis-ci.org/eugenenguyen/XBAuthentication)
[![Version](https://img.shields.io/cocoapods/v/XBAuthentication.svg?style=flat)](http://cocoadocs.org/docsets/XBAuthentication)
[![License](https://img.shields.io/cocoapods/l/XBAuthentication.svg?style=flat)](http://cocoadocs.org/docsets/XBAuthentication)
[![Platform](https://img.shields.io/cocoapods/p/XBAuthentication.svg?style=flat)](http://cocoadocs.org/docsets/XBAuthentication)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XBAuthentication is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "XBAuthentication"

## What's this?

XBAuthentication provide all the function refer to user system, include sign in, sign up, sign out, edit user's information, delete account. This is core system of XBMobile.

## Getting started

First, import XBAuthentication.h every where you need

Second, setup your web service domain.

```objective-c
[[XBAuthentication sharedInstance] setHost:@"http://example.com"];
```

Then, set the field that you want.

```objective-c
XBAuthentication *authenticator = [XBAuthentication sharedInstance];
authenticator.username = @"username";
authenticator.password = @"password";
```

And lastly, sign in or sign up as you wish.

```objective-c
[authenticator signup];
// OR, remember, OR, not AND
[authenticator signin];
```

You can use following function for your next step

```objective-c


// Forgot password (with username or email)
- (void)forgotPasswordForUser:(NSString *)user complete:(XBARequestCompletion)completion;

// Change password (with old / new password)
- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword complete:(XBARequestCompletion)completion;

// save / load session, using for remember me function

- (void)saveSession;
- (void)loadSession;


```

###Login with facebook

And last super good news, from now, you can login with facebook using XBAuthentication. with very simple following steps:

In AppDelegate file, add following code:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ...
    return [[XBAuthentication sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[XBAuthentication sharedInstance] applicationDidBecomeActive:application];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[XBAuthentication sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

```

And notice the log. it will remind you about what setting you missed in Info.plist. Just fill all the information as requested.
And now, when you ready to get user login, using:

```objective-c
[[XBAuthentication sharedInstance] startLoginFacebookWithCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
    ... do anything that you want with responseString, object (response object), errorCode, description and error. all in your hand now.
}];

```

## Author

eugenenguyen, xuanbinh91@gmail.com

## License

XBAuthentication is available under the MIT license. See the LICENSE file for more info.

