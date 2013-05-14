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

#import "UIPopoverController+BZExtensions.h"
#import "PasscodeDemoDefaultsKeys.h"
#import "PasscodeDemoViewController.h"
#import "PasscodeLockViewController.h"

#define kBlocksSection          0
#define kHelperSection          1
#define kSettingsSection        2

@interface PasscodeDemoViewController ()
@property(nonatomic,strong) UIPopoverController *passcodePopover;
@property(nonatomic,strong) BZPasscodeViewControllerHelper *helper;
- (BZPasscodeViewControllerHandler)passcodeViewControllerUnlockHandlerWithPasscode:(NSString *)passcode segueIdentifier:(NSString *)segueIdentifier;
- (void)dismissPasscodeViewController;
@end

@implementation PasscodeDemoViewController

- (void)dealloc {
    self.helper.delegate = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
    switch (indexPath.section) {
        case kBlocksSection:
        case kHelperSection:
            if (passcode) {
                cell.detailTextLabel.text = NSLocalizedString(@"On", @"");
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"Off", @"");
            }
            break;
        case kSettingsSection:
            cell.textLabel.enabled = (passcode != nil);
            break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSettingsSection) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
        return (passcode != nil) ? indexPath : nil;
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSettingsSection) {
        NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
        [tableView reloadData];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIViewController

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSString *passcode = [[NSUserDefaults standardUserDefaults] stringForKey:PasscodeKey];
    if (passcode) {
        BZPasscodeViewController *passcodeViewController = nil;
        if ([identifier isEqualToString:@"PresentPasscodeLockViewControllerWithBlocks"]) {
            passcodeViewController = [[BZPasscodeViewController alloc] init];
            passcodeViewController.handler = [self passcodeViewControllerUnlockHandlerWithPasscode:passcode segueIdentifier:identifier];
            passcodeViewController.text = NSLocalizedString(@"Enter your passcode", @"");
        } else if ([identifier isEqualToString:@"PresentPasscodeLockViewControllerWithHelpers"]) {
            BZPasscodeViewControllerUnlockHelper *helper = [[BZPasscodeViewControllerUnlockHelper alloc] initWithPasscode:passcode delegate:self context:(__bridge void *)identifier];
            passcodeViewController = helper.passcodeViewController;
            self.helper = helper;
        }
        if (passcodeViewController) {
            passcodeViewController.title = NSLocalizedString(@"Enter Passcode", @"");
            passcodeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPasscodeViewController)];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passcodeViewController];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:navigationController animated:YES completion:nil];
            } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                passcodeViewController.contentSizeForViewInPopover = [BZPasscodeViewController defaultContentSizeForView];
                passcodeViewController.modalInPopover = YES;
                self.passcodePopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
                [self.passcodePopover bz_presentPopoverInWindow:self.view.window animated:YES];
                UITableView *tableView = self.tableView;
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            }
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PasscodeLockViewController *passcodeLockViewController = [segue destinationViewController];
    passcodeLockViewController.usesHelper = [segue.identifier isEqualToString:@"PresentPasscodeLockViewControllerWithHelpers"];
}

- (void)viewWillAppear:(BOOL)animated {
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    if (indexPath) {
        [tableView reloadData];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [super viewWillAppear:animated];
}

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

#pragma mark - BZPasscodeViewControllerUnlockHelperDelegate

- (void)passcodeViewControllerUnlockHelperDidFinish:(BZPasscodeViewControllerUnlockHelper *)helper {
    [self performSegueWithIdentifier:(NSString *)helper.context sender:nil];
    [self dismissPasscodeViewController];
}

#pragma mark - Anonymous category

- (BZPasscodeViewControllerHandler)passcodeViewControllerUnlockHandlerWithPasscode:(NSString *)passcode segueIdentifier:(NSString *)segueIdentifier {
    __block NSUInteger failedAttempts = 0;
    return ^(NSString *enteredPasscode, NSString **text, NSString **detailText, BOOL *detailTextHighlighted) {
        *detailTextHighlighted = NO;
        if (![enteredPasscode isEqualToString:passcode]) {
            failedAttempts++;
            *detailText = [NSString stringWithFormat:((failedAttempts == 1) ? NSLocalizedString(@"%u Failed Passcode Attempt", @"") : NSLocalizedString(@"%u Failed Passcode Attempts", @"")), (unsigned long)failedAttempts];
            *detailTextHighlighted = YES;
            return BZPasscodeViewControllerResultInvalid;
        } else {
            [self performSegueWithIdentifier:segueIdentifier sender:nil];
            [self dismissPasscodeViewController];
            return BZPasscodeViewControllerResultDone;
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
