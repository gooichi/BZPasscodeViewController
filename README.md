# BZPasscodeViewController

BZPasscodeViewController is a view controller for iOS that allows a user to set, change or enter a simple 4-digit passcode.

![Change Passcode](https://github.com/baztokyo/BZPasscodeViewController/raw/master/images/change_passcode-568h~iphone.png "Change Passcode")
![Enter Passcode](https://github.com/baztokyo/BZPasscodeViewController/raw/master/images/enter_passcode~ipad.png "Enter Passcode")

## Features

* Provides an interface similar to Settings.app in your app
* Supports universal apps
* Separates the logic from the interface
* Open source BSD license

## Installation

1. Copy all the files from the BZPasscodeViewController folder to your project.

    If you are including BZPasscodeViewController in your project that uses Objective-C Automatic Reference Counting (ARC) enabled, you will need to add the `-fno-objc-arc` compiler flag on all of the BZPasscodeViewController source files. To do this in Xcode, go to your active target and select the **Build Phases** tab. In the **Compiler Flags** column of the **Compile Sources** section, add `-fno-objc-arc` for each of the BZPasscodeViewController source files.

2. Link against the following frameworks:
    * CoreGraphics.framework
    * Foundation.framework
    * UIKit.framework
    * AVFoundation.framework (optional)

    (optional) To enable the keypad tap sound, link to the AVFoundation.framework and add the `-DBZ_USE_SOUND` compiler flag on the BZPasscodeViewController.m source file.

## Sample Application

BZPasscodeViewController comes with PasscodeDemo app that demonstrates how to use it to guide you in development. To build and run PasscodeDemo app, open the PasscodeDemo project with Xcode 4.6 or later.

## License

BZPasscodeViewController is available under the 2-clause BSD license. See the LICENSE file for more info.
