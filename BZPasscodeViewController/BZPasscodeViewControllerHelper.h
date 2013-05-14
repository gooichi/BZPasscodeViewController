/*
 * Copyright (C) 2013 Ba-Z Communication Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/NSObject.h>
#import "BZPasscodeViewController.h"

#ifndef NS_RETURNS_NOT_RETAINED
#define NS_RETURNS_NOT_RETAINED
#endif

@protocol BZPasscodeViewControllerUnlockHelperDelegate;
@protocol BZPasscodeViewControllerSetHelperDelegate;

@interface BZPasscodeViewControllerHelper : NSObject <BZPasscodeViewControllerDelegate> {
    id                          delegate_;
    void                        *context_;
    NSString                    *passcode_;
    BZPasscodeViewController    *passcodeViewController_;
    NSUInteger                  failedAttempts_;
    NSDate                      *failedDate_;
}
@property(nonatomic,assign) id delegate;
@property(nonatomic,assign) void *context;
@property(nonatomic,copy) NSString *passcode;
@property(nonatomic,readonly,retain) BZPasscodeViewController *passcodeViewController;

@end

@interface BZPasscodeViewControllerUnlockHelper : BZPasscodeViewControllerHelper

- (id)initWithPasscode:(NSString *)passcode delegate:(id <BZPasscodeViewControllerUnlockHelperDelegate>)delegate context:(void *)context;

@end

@protocol BZPasscodeViewControllerUnlockHelperDelegate <NSObject>
@required
- (void)passcodeViewControllerUnlockHelperDidFinish:(BZPasscodeViewControllerUnlockHelper *)helper;
@end

@interface BZPasscodeViewControllerSetHelper : BZPasscodeViewControllerHelper {
    NSString    *newPasscode_;
    BOOL        unlocked_;
    NSInteger   error_;
}
@property(nonatomic,readonly,copy) NSString *newPasscode NS_RETURNS_NOT_RETAINED;

- (id)initWithPasscode:(NSString *)passcode delegate:(id <BZPasscodeViewControllerSetHelperDelegate>)delegate context:(void *)context;

@end

@protocol BZPasscodeViewControllerSetHelperDelegate <NSObject>
@required
- (void)passcodeViewControllerSetHelperDidFinish:(BZPasscodeViewControllerSetHelper *)helper;
@end
