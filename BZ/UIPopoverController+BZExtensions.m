//
//  UIPopoverController+BZExtensions.m
//
//  Copyright 2010 Ba-Z Communication Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopoverController+BZExtensions.h"

#define LANDSCAPE_CENTER_Y 298.0
#define STATUS_BAR_HEIGHT 20.0

@implementation UIPopoverController (BZExtensions)

- (void)bz_presentPopoverInWindow:(UIWindow *)window animated:(BOOL)animated {
    if ([[UIDevice currentDevice].systemVersion compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending) {
        // 4.3.x or earlier
        UIApplication *UIApp = [UIApplication sharedApplication];
        CGPoint point;
        if (UIInterfaceOrientationIsPortrait(UIApp.statusBarOrientation)) {
            point = window.center;
        } else {
            if ([[UIDevice currentDevice].systemVersion compare:@"4.2" options:NSNumericSearch] == NSOrderedAscending) {
                // 3.2.x
                point = CGPointMake(window.center.y, LANDSCAPE_CENTER_Y);
            } else {
                // 4.2 - 4.3.x
                point = CGPointMake(window.center.y, window.center.x);
            }
        }
        if (!UIApp.statusBarHidden) {
            point.y += (STATUS_BAR_HEIGHT / 2);
        }
        CGRect rect = CGRectMake(point.x, point.y, 0, 0);
        [self presentPopoverFromRect:rect inView:window permittedArrowDirections:0 animated:animated];
    } else {
        // 5.0 or later
        UIApplication *UIApp = [UIApplication sharedApplication];
        CGPoint point;
        point = window.center;
        switch (UIApp.statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            point.y += (STATUS_BAR_HEIGHT / 2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            point.y -= (STATUS_BAR_HEIGHT / 2);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            point.x += (STATUS_BAR_HEIGHT / 2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            point.x -= (STATUS_BAR_HEIGHT / 2);
            break;
        }
        // -[UIPopoverController presentPopoverFromRect:inView:permittedArrowDirections:animated:]: the rect passed in to this method must have non-zero width and height. This will be an exception in a future release.
        CGRect rect = CGRectMake(point.x, point.y, 1, 1);
        [self presentPopoverFromRect:rect inView:window permittedArrowDirections:0 animated:animated];
    }
}

@end
