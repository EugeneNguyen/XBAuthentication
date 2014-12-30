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



```

## Author

eugenenguyen, xuanbinh91@gmail.com

## License

XBAuthentication is available under the MIT license. See the LICENSE file for more info.

