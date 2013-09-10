//
//  BZNavigationController.m
//
//  Copyright 2013 Ba-Z Communication Inc. All rights reserved.
//

#import "BZNavigationController.h"

@implementation BZNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAutorotate = YES;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
        } else {
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
        }
        self.preferredInterfaceOrientationForPresentation = UIInterfaceOrientationPortrait;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.shouldAutorotate = YES;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
        } else {
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
        }
        self.preferredInterfaceOrientationForPresentation = UIInterfaceOrientationPortrait;
    }
    return self;
}

@end
