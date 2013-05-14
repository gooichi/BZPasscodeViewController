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

#import <Foundation/Foundation.h>
#import "BZPasscodeViewControllerHelper.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#error This file does not support Objective-C Automatic Reference Counting (ARC)
#endif

#define kFailedAttemptsKey @"BZPasscodeViewControllerFailedAttempts"
#define kFailedDateKey     @"BZPasscodeViewControllerFailedDate"

@interface BZPasscodeViewControllerHelper ()
@property(nonatomic,readwrite,retain) BZPasscodeViewController *passcodeViewController;
@property(nonatomic) NSUInteger failedAttempts;
@property(nonatomic,retain) NSDate *failedDate;
- (id)initWithPasscode:(NSString *)passcode;
- (void)saveDefaults;
- (void)restoreDefaults;
- (void)updatePasscodeView;
- (NSTimeInterval)waitingTimeIntervalSinceNow;
- (void)timerFired:(NSTimer *)timer;
@end

@implementation BZPasscodeViewControllerHelper

@synthesize delegate = delegate_;
@synthesize context = context_;
@synthesize passcode = passcode_;
@synthesize passcodeViewController = passcodeViewController_;
@synthesize failedAttempts = failedAttempts_;
@synthesize failedDate = failedDate_;

- (id)init {
    return [self initWithPasscode:nil];
}

- (void)dealloc {
    self.delegate = nil;
    self.context = NULL;
    self.passcode = nil;
    if (passcodeViewController_) {
        passcodeViewController_.delegate = nil;
        self.passcodeViewController = nil;
    }
    self.failedDate = nil;
    [super dealloc];
}

- (BZPasscodeViewController *)passcodeViewController {
    if (!passcodeViewController_) {
        self.passcodeViewController = [[[BZPasscodeViewController alloc] init] autorelease];
        passcodeViewController_.delegate = self;
        [self updatePasscodeView];
        if (!passcodeViewController_.keypadEnabled) {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        }
    }
    return passcodeViewController_;
}

#pragma mark - BZPasscodeViewControllerDelegate

- (BZPasscodeViewControllerResult)passcodeViewController:(BZPasscodeViewController *)controller didEnterPasscode:(NSString *)passcode {
    [self doesNotRecognizeSelector:_cmd];
    return BZPasscodeViewControllerResultInvalid;
}

#pragma mark - Anonymous category

- (id)initWithPasscode:(NSString *)passcode {
    self = [super init];
    if (self) {
        self.passcode = passcode;
        [self restoreDefaults];
    }
    return self;
}

- (void)saveDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:failedAttempts_ forKey:kFailedAttemptsKey];
    [defaults setObject:failedDate_ forKey:kFailedDateKey];
}

- (void)restoreDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.failedAttempts = [defaults integerForKey:kFailedAttemptsKey];
    self.failedDate = [defaults objectForKey:kFailedDateKey];
}

- (void)updatePasscodeView {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSTimeInterval)waitingTimeIntervalSinceNow {
    switch (failedAttempts_) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            return 0;
        case 6:
            return ([failedDate_ timeIntervalSinceReferenceDate] + (60 * 1) - [NSDate timeIntervalSinceReferenceDate]);
        case 7:
            return ([failedDate_ timeIntervalSinceReferenceDate] + (60 * 5) - [NSDate timeIntervalSinceReferenceDate]);
        case 8:
            return ([failedDate_ timeIntervalSinceReferenceDate] + (60 * 15) - [NSDate timeIntervalSinceReferenceDate]);
        case 9:
        default:
            return ([failedDate_ timeIntervalSinceReferenceDate] + (60 * 60) - [NSDate timeIntervalSinceReferenceDate]);
    }
}

- (void)timerFired:(NSTimer *)timer {
    if (!passcodeViewController_.parentViewController) {
        [timer invalidate];
    } else {
        [self updatePasscodeView];
        if (passcodeViewController_.keypadEnabled) {
            [timer invalidate];
        }
    }
}

@end

@implementation BZPasscodeViewControllerUnlockHelper

- (id)init {
    return [self initWithPasscode:nil delegate:nil context:NULL];
}

- (id)initWithPasscode:(NSString *)passcode delegate:(id <BZPasscodeViewControllerUnlockHelperDelegate>)delegate context:(void *)context {
    self = [super initWithPasscode:passcode];
    if (self) {
        self.delegate = delegate;
        self.context= context;
    }
    return self;
}

#pragma mark - BZPasscodeViewControllerDelegate

- (BZPasscodeViewControllerResult)passcodeViewController:(BZPasscodeViewController *)controller didEnterPasscode:(NSString *)passcode {
    if (![passcode isEqualToString:passcode_]) {
        self.failedAttempts++;
        self.failedDate = [NSDate date];
        [self saveDefaults];
        [self updatePasscodeView];
        if (!passcodeViewController_.keypadEnabled) {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        }
        return BZPasscodeViewControllerResultInvalid;
    } else {
        self.failedAttempts = 0;
        self.failedDate = nil;
        [self saveDefaults];
        if ([delegate_ respondsToSelector:@selector(passcodeViewControllerUnlockHelperDidFinish:)]) {
            [delegate_ passcodeViewControllerUnlockHelperDidFinish:self];
        }
        return BZPasscodeViewControllerResultDone;
    }
}

#pragma mark - Anonymous category

- (void)updatePasscodeView {
    NSTimeInterval waitingTime = [self waitingTimeIntervalSinceNow];
    passcodeViewController_.detailTextHighlighted = NO;
    if (waitingTime > 0) {
        NSUInteger minutes = ceil(waitingTime / 60);
        passcodeViewController_.text = [NSString stringWithFormat:((minutes == 1) ? NSLocalizedString(@"Try again in %u minute", @"") : NSLocalizedString(@"Try again in %u minutes", @"")), minutes];
        passcodeViewController_.keypadEnabled = NO;
    } else {
        passcodeViewController_.text = NSLocalizedString(@"Enter your passcode", @"");
        passcodeViewController_.keypadEnabled = YES;
    }
    switch (failedAttempts_) {
        case 0:
            passcodeViewController_.detailText = nil;
            break;
        case 1:
            passcodeViewController_.detailText = [NSString stringWithFormat:NSLocalizedString(@"%u Failed Passcode Attempt", @""), failedAttempts_];
            passcodeViewController_.detailTextHighlighted = YES;
            break;
        default:
            passcodeViewController_.detailText = [NSString stringWithFormat:NSLocalizedString(@"%u Failed Passcode Attempts", @""), failedAttempts_];
            passcodeViewController_.detailTextHighlighted = YES;
            break;
    }
}

@end

enum {
    kPasscodeNoError       = 0,
    kPasscodeSameError     = 1,
    kPasscodeMismatchError = 2
};

@interface BZPasscodeViewControllerSetHelper ()
@property(nonatomic,readwrite,copy) NSString *newPasscode NS_RETURNS_NOT_RETAINED;
@property(nonatomic,getter=isUnlocked) BOOL unlocked;
@property(nonatomic) NSInteger error;
@end

@implementation BZPasscodeViewControllerSetHelper

@synthesize newPasscode = newPasscode_;
@synthesize unlocked = unlocked_;
@synthesize error = error_;

- (id)init {
    return [self initWithPasscode:nil delegate:nil context:NULL];
}

- (id)initWithPasscode:(NSString *)passcode delegate:(id <BZPasscodeViewControllerSetHelperDelegate>)delegate context:(void *)context {
    self = [super initWithPasscode:passcode];
    if (self) {
        self.delegate = delegate;
        self.context= context;
    }
    return self;
}

- (void)dealloc {
    self.newPasscode = nil;
    [super dealloc];
}

#pragma mark - BZPasscodeViewControllerDelegate

- (BZPasscodeViewControllerResult)passcodeViewController:(BZPasscodeViewController *)controller didEnterPasscode:(NSString *)passcode {
    if (passcode_ && !unlocked_) {
        // unlock
        if (![passcode isEqualToString:passcode_]) {
            self.failedAttempts++;
            self.failedDate = [NSDate date];
            [self saveDefaults];
            [self updatePasscodeView];
            if (!passcodeViewController_.keypadEnabled) {
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
            }
            return BZPasscodeViewControllerResultInvalid;
        } else {
            self.unlocked = YES;
            self.failedAttempts = 0;
            self.failedDate = nil;
            [self saveDefaults];
            [self updatePasscodeView];
            return BZPasscodeViewControllerResultContinue;
        }
    } else {
        // set/change
        if (!newPasscode_) {
            // 1st stage
            if (passcode_ && [passcode isEqualToString:passcode_]) {
                self.error = kPasscodeSameError;
                [self updatePasscodeView];
                return BZPasscodeViewControllerResultInvalid;
            } else {
                self.newPasscode = passcode;
                self.error = kPasscodeNoError;
                [self updatePasscodeView];
                return BZPasscodeViewControllerResultContinue;
            }
        } else {
            // 2nd stage
            if (![passcode isEqualToString:newPasscode_]) {
                self.newPasscode = nil;
                self.error = kPasscodeMismatchError;
                [self updatePasscodeView];
                return BZPasscodeViewControllerResultContinue;
            } else {
                if ([delegate_ respondsToSelector:@selector(passcodeViewControllerSetHelperDidFinish:)]) {
                    [delegate_ passcodeViewControllerSetHelperDidFinish:self];
                }
                return BZPasscodeViewControllerResultDone;
            }
        }
    }
}

#pragma mark - Anonymous category

- (void)updatePasscodeView {
    passcodeViewController_.detailTextHighlighted = NO;
    if (passcode_ && !unlocked_) {
        // unlock
        NSTimeInterval waitingTime = [self waitingTimeIntervalSinceNow];
        if (waitingTime > 0) {
            NSUInteger minutes = ceil(waitingTime / 60);
            passcodeViewController_.text = [NSString stringWithFormat:((minutes == 1) ? NSLocalizedString(@"Try again in %u minute", @"") : NSLocalizedString(@"Try again in %u minutes", @"")), minutes];
            passcodeViewController_.keypadEnabled = NO;
        } else {
            passcodeViewController_.text = NSLocalizedString(@"Enter your old passcode", @"");
            passcodeViewController_.keypadEnabled = YES;
        }
        switch (failedAttempts_) {
            case 0:
                passcodeViewController_.detailText = nil;
                break;
            case 1:
                passcodeViewController_.detailText = [NSString stringWithFormat:NSLocalizedString(@"%u Failed Passcode Attempt", @""), failedAttempts_];
                passcodeViewController_.detailTextHighlighted = YES;
                break;
            default:
                passcodeViewController_.detailText = [NSString stringWithFormat:NSLocalizedString(@"%u Failed Passcode Attempts", @""), failedAttempts_];
                passcodeViewController_.detailTextHighlighted = YES;
                break;
        }
    } else {
        // set/change
        if (!newPasscode_) {
            // 1st stage
            if (!passcode_) {
                // set
                passcodeViewController_.text = NSLocalizedString(@"Enter a passcode", @"");
                switch (error_) {
                    case kPasscodeMismatchError:
                        passcodeViewController_.detailText = NSLocalizedString(@"Passcodes did not match. Try again.", @"");
                        break;
                    default:
                        passcodeViewController_.detailText = nil;
                        break;
                }
            } else {
                // change
                passcodeViewController_.text = NSLocalizedString(@"Enter your new passcode", @"");
                switch (error_) {
                    case kPasscodeSameError:
                        passcodeViewController_.detailText = NSLocalizedString(@"Enter a different passcode. Cannot re-use the same passcode.", @"");
                        break;
                    case kPasscodeMismatchError:
                        passcodeViewController_.detailText = NSLocalizedString(@"Passcodes did not match. Try again.", @"");
                        break;
                    default:
                        passcodeViewController_.detailText = nil;
                        break;
                }
            }
        } else {
            // 2nd stage
            if (!passcode_) {
                // set
                passcodeViewController_.text = NSLocalizedString(@"Re-enter your passcode", @"");
            } else {
                // change
                passcodeViewController_.text = NSLocalizedString(@"Re-enter your new passcode", @"");
            }
            passcodeViewController_.detailText = nil;
        }
    }
}

@end
