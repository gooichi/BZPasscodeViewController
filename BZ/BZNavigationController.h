//
//  BZNavigationController.h
//
//  Copyright 2013 Ba-Z Communication Inc. All rights reserved.
//

#import <UIKit/UINavigationController.h>

@interface BZNavigationController : UINavigationController

@property(nonatomic) BOOL shouldAutorotate;
@property(nonatomic) NSUInteger supportedInterfaceOrientations;
@property(nonatomic) UIInterfaceOrientation preferredInterfaceOrientationForPresentation;

@end
