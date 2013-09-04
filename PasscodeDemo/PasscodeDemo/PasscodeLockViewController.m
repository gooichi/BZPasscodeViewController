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

#import "BZNavigationController.h"
#import "UIPopoverController+BZExtensions.h"
#import "PasscodeDemoDefaultsKeys.h"
#import "PasscodeLockViewController.h"

#define kOnOffRow       0
#define kChangeRow      1

@interface PasscodeLockViewController ()
@property(nonatomic,strong) UIPopoverController *passcodePopover;
@property(nonatomic,strong) BZPasscodeViewControllerHelper *helper;
- (BZPasscodeViewControllerHandler)passcodeViewControllerSetHandler;
- (BZPasscodeViewControllerHandler)passcodeViewControllerUnlockHandlerWithPasscode:(NSString *)passcode;
- (BZPasscodeViewControllerHandler)passcodeViewControllerChangeHandlerWithPasscode:(NSString *)passcode;
- (void)dismissPasscodeViewController;
@end

@implementation PasscodeLockViewController

- (void)dealloc {
    self.helper.delegate = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
    switch (indexPath.row) {
        case kOnOffRow:
            if (passcode) {
                cell.textLabel.text = NSLocalizedString(@"Turn Passcode Off", @"");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Turn Passcode On", @"");
            }
            break;
        case kChangeRow:
            cell.textLabel.enabled = (passcode != nil);
            break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kChangeRow) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
        return (passcode != nil) ? indexPath : nil;
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
    BZPasscodeViewController *passcodeViewController = nil;
    switch (indexPath.row) {
        case kOnOffRow:
            if (!passcode) {
                if (!self.usesHelper) {
                    passcodeViewController = [[BZPasscodeViewController alloc] init];
                    passcodeViewController.handler = [self passcodeViewControllerSetHandler];
                    passcodeViewController.text = NSLocalizedString(@"Enter a passcode", @"");
                } else {
                    BZPasscodeViewControllerSetHelper *helper = [[BZPasscodeViewControllerSetHelper alloc] initWithPasscode:nil delegate:self context:NULL];
                    passcodeViewController = helper.passcodeViewController;
                    self.helper = helper;
                }
                passcodeViewController.title = NSLocalizedString(@"Set Passcode", @"");
            } else {
                if (!self.usesHelper) {
                    passcodeViewController = [[BZPasscodeViewController alloc] init];
                    passcodeViewController.handler = [self passcodeViewControllerUnlockHandlerWithPasscode:passcode];
                    passcodeViewController.text = NSLocalizedString(@"Enter your passcode", @"");
                } else {
                    BZPasscodeViewControllerUnlockHelper *helper = [[BZPasscodeViewControllerUnlockHelper alloc] initWithPasscode:passcode delegate:self context:NULL];
                    passcodeViewController = helper.passcodeViewController;
                    self.helper = helper;
                }
                passcodeViewController.title = NSLocalizedString(@"Turn off Passcode", @"");
            }
            break;
        case kChangeRow:
            if (!self.usesHelper) {
                passcodeViewController = [[BZPasscodeViewController alloc] init];
                passcodeViewController.handler = [self passcodeViewControllerChangeHandlerWithPasscode:passcode];
                passcodeViewController.text = NSLocalizedString(@"Enter your old passcode", @"");
            } else {
                BZPasscodeViewControllerSetHelper *helper = [[BZPasscodeViewControllerSetHelper alloc] initWithPasscode:passcode delegate:self context:NULL];
                passcodeViewController = helper.passcodeViewController;
                self.helper = helper;
            }
            passcodeViewController.title = NSLocalizedString(@"Change Passcode", @"");
            break;
    }
    if (passcodeViewController) {
        passcodeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPasscodeViewController)];
        BZNavigationController *navigationController = [[BZNavigationController alloc] initWithRootViewController:passcodeViewController];
        navigationController.shouldAutorotate = passcodeViewController.shouldAutorotate;
        navigationController.supportedInterfaceOrientations = passcodeViewController.supportedInterfaceOrientations;
        navigationController.preferredInterfaceOrientationForPresentation = passcodeViewController.preferredInterfaceOrientationForPresentation;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:navigationController animated:YES completion:nil];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            passcodeViewController.contentSizeForViewInPopover = [BZPasscodeViewController defaultContentSizeForView];
            passcodeViewController.modalInPopover = YES;
            self.passcodePopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            [self.passcodePopover bz_presentPopoverInWindow:self.view.window animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BZPasscodeViewControllerSetHelperDelegate

- (void)passcodeViewControllerSetHelperDidFinish:(BZPasscodeViewControllerSetHelper *)helper {
    [[NSUserDefaults standardUserDefaults] setObject:helper.newPasscode forKey:PasscodeKey];
    if (!helper.passcode) {
        [self.tableView reloadData];
    }
    [self dismissPasscodeViewController];
}

#pragma mark - BZPasscodeViewControllerUnlockHelperDelegate

- (void)passcodeViewControllerUnlockHelperDidFinish:(BZPasscodeViewControllerUnlockHelper *)helper {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PasscodeKey];
    [self.tableView reloadData];
    [self dismissPasscodeViewController];
}

#pragma mark - UIViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.passcodePopover dismissPopoverAnimated:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.passcodePopover bz_presentPopoverInWindow:self.view.window animated:NO];
    }
}

#pragma mark - Anonymous category

- (BZPasscodeViewControllerHandler)passcodeViewControllerSetHandler {
    __block NSString * newPasscode = nil;
    return ^(NSString *enteredPasscode, NSString **text, NSString **detailText, BOOL *detailTextHighlighted) {
        *detailTextHighlighted = NO;
        if (!newPasscode) {
            newPasscode = enteredPasscode;
            *text = NSLocalizedString(@"Re-enter your passcode", @"");
            *detailText = nil;
            return BZPasscodeViewControllerResultContinue;
        } else {
            if (![enteredPasscode isEqualToString:newPasscode]) {
                newPasscode = nil;
                *text = NSLocalizedString(@"Enter a passcode", @"");
                *detailText = NSLocalizedString(@"Passcodes did not match. Try again.", @"");
                return BZPasscodeViewControllerResultContinue;
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:newPasscode forKey:PasscodeKey];
                [self.tableView reloadData];
                [self dismissPasscodeViewController];
                return BZPasscodeViewControllerResultDone;
            }
        }
    };
}

- (BZPasscodeViewControllerHandler)passcodeViewControllerUnlockHandlerWithPasscode:(NSString *)passcode {
    __block NSUInteger failedAttempts = 0;
    return ^(NSString *enteredPasscode, NSString **text, NSString **detailText, BOOL *detailTextHighlighted) {
        *detailTextHighlighted = NO;
        if (![enteredPasscode isEqualToString:passcode]) {
            failedAttempts++;
            *detailText = [NSString stringWithFormat:((failedAttempts == 1) ? NSLocalizedString(@"%lu Failed Passcode Attempt", @"") : NSLocalizedString(@"%lu Failed Passcode Attempts", @"")), (unsigned long)failedAttempts];
            *detailTextHighlighted = YES;
            return BZPasscodeViewControllerResultInvalid;
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:PasscodeKey];
            [self.tableView reloadData];
            [self dismissPasscodeViewController];
            return BZPasscodeViewControllerResultDone;
        }
    };
}

- (BZPasscodeViewControllerHandler)passcodeViewControllerChangeHandlerWithPasscode:(NSString *)passcode {
    __block BOOL unlocked = NO;
    __block NSUInteger failedAttempts = 0;
    __block NSString *newPasscode = nil;
    return ^(NSString *enteredPasscode, NSString **text, NSString **detailText, BOOL *detailTextHighlighted) {
        *detailTextHighlighted = NO;
        if (!unlocked) {
            if (![enteredPasscode isEqualToString:passcode]) {
                failedAttempts++;
                *detailText = [NSString stringWithFormat:((failedAttempts == 1) ? NSLocalizedString(@"%lu Failed Passcode Attempt", @"") : NSLocalizedString(@"%lu Failed Passcode Attempts", @"")), (unsigned long)failedAttempts];
                *detailTextHighlighted = YES;
                return BZPasscodeViewControllerResultInvalid;
            } else {
                unlocked = YES;
                *text = NSLocalizedString(@"Enter your new passcode", @"");
                *detailText = nil;
                return BZPasscodeViewControllerResultContinue;
            }
        } else {
            if (!newPasscode) {
                if ([enteredPasscode isEqualToString:passcode]) {
                    *detailText = NSLocalizedString(@"Enter a different passcode. Cannot re-use the same passcode.", @"");
                    return BZPasscodeViewControllerResultInvalid;
                } else {
                    newPasscode = enteredPasscode;
                    *text = NSLocalizedString(@"Re-enter your new passcode", @"");
                    *detailText = nil;
                    return BZPasscodeViewControllerResultContinue;
                }
            } else {
                if (![enteredPasscode isEqualToString:newPasscode]) {
                    newPasscode = nil;
                    *detailText = NSLocalizedString(@"Passcodes did not match. Try again.", @"");
                    return BZPasscodeViewControllerResultContinue;
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:newPasscode forKey:PasscodeKey];
                    [self dismissPasscodeViewController];
                    return BZPasscodeViewControllerResultDone;
                }
            }
        }
    };
}

- (void)dismissPasscodeViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.passcodePopover dismissPopoverAnimated:YES];
        self.passcodePopover = nil;
    }
    self.helper.delegate = nil;
    self.helper = nil;
}

@end
