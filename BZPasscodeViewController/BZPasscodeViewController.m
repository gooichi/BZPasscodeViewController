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

#if BZ_USE_SOUND
#import <AVFoundation/AVFoundation.h>
#endif
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BZPasscodeViewController.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#error This file does not support Objective-C Automatic Reference Counting (ARC)
#endif

#if !defined(__IPHONE_4_0) || __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_4_0
@interface UIImage (AvailableInIOS4_0)
@property(nonatomic,readonly) CGFloat scale;
@end
#endif

#if !defined(__IPHONE_5_0) || __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_5_0
@interface UIImage (AvailableInIOS5_0)
- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets;
@end
#endif

#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
enum {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight)
};
typedef NSUInteger UIInterfaceOrientationMask;
#endif

#define kDefaultPasscodeLength  4

@interface BZPasscodeFieldController ()
@property(nonatomic,copy) NSString *passcode;
@property(nonatomic,copy) NSString *text;
@property(nonatomic,copy) NSString *detailText;
@property(nonatomic,getter=isDetailTextHighlighted) BOOL detailTextHighlighted;
- (void)updatePasscodeFields;
- (void)updateDetailTextLabel;
@end

@implementation BZPasscodeFieldController

@synthesize passcode0Field = passcode0Field_;
@synthesize passcode1Field = passcode1Field_;
@synthesize passcode2Field = passcode2Field_;
@synthesize passcode3Field = passcode3Field_;
@synthesize textLabel = textLabel_;
@synthesize detailTextLabel = detailTextLabel_;
@synthesize detailTextBackground = detailTextBackground_;
@synthesize passcode = passcode_;
@synthesize text = text_;
@synthesize detailText = detailText_;
@synthesize detailTextHighlighted = detailTextHighlighted_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        for (NSString *keyPath in [NSArray arrayWithObjects:@"passcode", @"text", @"detailText", @"detailTextHighlighted", nil]) {
            [self addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (NSString *keyPath in [NSArray arrayWithObjects:@"passcode", @"text", @"detailText", @"detailTextHighlighted", nil]) {
            [self addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
    return self;
}

- (void)dealloc {
    for (NSString *keyPath in [NSArray arrayWithObjects:@"passcode", @"text", @"detailText", @"detailTextHighlighted", nil]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
    self.passcode0Field = nil;
    self.passcode1Field = nil;
    self.passcode2Field = nil;
    self.passcode3Field = nil;
    self.textLabel = nil;
    self.detailTextLabel = nil;
    self.detailTextBackground = nil;
    self.passcode = nil;
    self.text = nil;
    self.detailText = nil;
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 320, 200);
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BZPasscodeViewController" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:@"passcode_field_background_opaque" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending) {
        // 4.3.x or earlier
        image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:26];
    } else {
        // 5.0 or later
        UIEdgeInsets capInsets = UIEdgeInsetsMake(26, 5, 26, 5);
        image = [image resizableImageWithCapInsets:capInsets];
    }
    [passcode0Field_ setBackground:image];
    [passcode1Field_ setBackground:image];
    [passcode2Field_ setBackground:image];
    [passcode3Field_ setBackground:image];
    [self updatePasscodeFields];
    textLabel_.text = text_;
    detailTextLabel_.text = detailText_;
    path = [bundle pathForResource:@"detail_text_highlight_background" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending) {
        // 4.3.x or earlier
        image = [image stretchableImageWithLeftCapWidth:13 topCapHeight:13];
    } else {
        // 5.0 or later
        UIEdgeInsets capInsets = UIEdgeInsetsMake(13, 13, 13, 13);
        image = [image resizableImageWithCapInsets:capInsets];
    }
    detailTextBackground_.image = image;
    [self updateDetailTextLabel];
}

- (void)viewDidUnload {
    self.passcode0Field = nil;
    self.passcode1Field = nil;
    self.passcode2Field = nil;
    self.passcode3Field = nil;
    self.textLabel = nil;
    self.detailTextLabel = nil;
    self.detailTextBackground = nil;
    [super viewDidUnload];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self]) {
        if ([keyPath isEqualToString:@"passcode"]) {
            if ([self isViewLoaded]) {
                [self updatePasscodeFields];
            }
        } else if ([keyPath isEqualToString:@"text"]) {
            if ([self isViewLoaded]) {
                textLabel_.text = text_;
            }
        } else if ([keyPath isEqualToString:@"detailText"]) {
            if ([self isViewLoaded]) {
                detailTextLabel_.text = detailText_;
                [self updateDetailTextLabel];
            }
        } else if ([keyPath isEqualToString:@"detailTextHighlighted"]) {
            if ([self isViewLoaded]) {
                [self updateDetailTextLabel];
            }
        } else {
            NSAssert2(NO, @"*** %s: unknown keyPath \"%@\"", __PRETTY_FUNCTION__, keyPath);
        }
    } else {
        NSAssert3(NO, @"*** %s: unknown keyPath \"%@\" of %@", __PRETTY_FUNCTION__, keyPath, object);
    }
}

#pragma mark - Anonymous category

- (void)updatePasscodeFields {
    NSAssert1([self isViewLoaded], @"*** %s: view is not loaded", __PRETTY_FUNCTION__);
    for (NSUInteger i = 0; i < kDefaultPasscodeLength; i++) {
        NSString *code = ([passcode_ length] > i) ? [passcode_ substringWithRange:NSMakeRange(i, 1)] : nil;
        NSString *keyPath = [NSString stringWithFormat:@"passcode%luField.text", (unsigned long)i];
        [self setValue:code forKeyPath:keyPath];
    }
}

- (void)updateDetailTextLabel {
    NSAssert1([self isViewLoaded], @"*** %s: view is not loaded", __PRETTY_FUNCTION__);
    if (detailTextHighlighted_) {
        detailTextLabel_.textColor = [UIColor whiteColor];
        detailTextLabel_.font = [UIFont boldSystemFontOfSize:14];
        detailTextLabel_.shadowColor = [UIColor blackColor];
        detailTextLabel_.shadowOffset = CGSizeMake(0, -1);
        CGSize size = [detailText_ sizeWithFont:detailTextLabel_.font constrainedToSize:detailTextLabel_.bounds.size lineBreakMode:detailTextLabel_.lineBreakMode];
        size.width += 36;
        size.height += 9;
        detailTextBackground_.frame = CGRectMake(CGRectGetMinX(detailTextLabel_.frame) + (CGRectGetWidth(detailTextLabel_.frame) - size.width) / 2 , CGRectGetMinY(detailTextLabel_.frame) +  (CGRectGetHeight(detailTextLabel_.frame) - size.height) / 2, size.width, size.height);
        detailTextBackground_.hidden = NO;
    } else {
        detailTextLabel_.textColor = [UIColor colorWithRed:((CGFloat)76 / 255) green:((CGFloat)86 / 255) blue:((CGFloat)107 / 255) alpha:1];
        detailTextLabel_.font = [UIFont systemFontOfSize:14];
        detailTextLabel_.shadowColor = [UIColor whiteColor];
        detailTextLabel_.shadowOffset = CGSizeMake(0, 1);
        detailTextBackground_.hidden = YES;
    }
}

@end

@interface BZPasscodeViewController ()
@property(nonatomic,readwrite,assign) BZPasscodeFieldController *currentPasscodeFieldController;
#if BZ_USE_SOUND
@property(nonatomic,retain) AVAudioPlayer *tockPlayer;
- (void)playTockSound;
#endif
- (void)didEnterPasscode;
- (void)togglePasscodeFields;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@implementation BZPasscodeViewController

@synthesize passcodeFieldController1 = passcodeFieldController1_;
@synthesize passcodeFieldController2 = passcodeFieldController2_;
@synthesize currentPasscodeFieldController = currentPasscodeFieldController_;
@synthesize keypadImageView = keypadImageView_;
@synthesize keypad1Button = keypad1Button_;
@synthesize keypad2Button = keypad2Button_;
@synthesize keypad3Button = keypad3Button_;
@synthesize keypad4Button = keypad4Button_;
@synthesize keypad5Button = keypad5Button_;
@synthesize keypad6Button = keypad6Button_;
@synthesize keypad7Button = keypad7Button_;
@synthesize keypad8Button = keypad8Button_;
@synthesize keypad9Button = keypad9Button_;
@synthesize keypad0Button = keypad0Button_;
@synthesize keypadDelButton = keypadDelButton_;
@synthesize keypadEnabled = keypadEnabled_;
#if BZ_USE_SOUND
@synthesize tockPlayer = tockPlayer_;
@synthesize soundEnabled = soundEnabled_;
#endif
@synthesize delegate = delegate_;
#if NS_BLOCKS_AVAILABLE
@synthesize handler = handler_;
#endif
@synthesize text = text_;
@synthesize detailText = detailText_;
@synthesize detailTextHighlighted = detailTextHighlighted_;

+ (CGSize)defaultContentSizeForView {
    return CGSizeMake(320, 416);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        keypadEnabled_ = YES;
#if BZ_USE_SOUND
        soundEnabled_ = YES;
#endif
        for (NSString *keyPath in [NSArray arrayWithObjects:@"keypadEnabled", @"text", @"detailText", @"detailTextHighlighted", nil]) {
            [self addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        keypadEnabled_ = YES;
#if BZ_USE_SOUND
        soundEnabled_ = YES;
#endif
        for (NSString *keyPath in [NSArray arrayWithObjects:@"keypadEnabled", @"text", @"detailText", @"detailTextHighlighted", nil]) {
            [self addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
    return self;
}

- (void)dealloc {
    for (NSString *keyPath in [NSArray arrayWithObjects:@"keypadEnabled", @"text", @"detailText", @"detailTextHighlighted", nil]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
    self.passcodeFieldController1 = nil;
    self.passcodeFieldController2 = nil;
    self.currentPasscodeFieldController = nil;
    self.keypadImageView = nil;
    self.keypad1Button = nil;
    self.keypad2Button = nil;
    self.keypad3Button = nil;
    self.keypad4Button = nil;
    self.keypad5Button = nil;
    self.keypad6Button = nil;
    self.keypad7Button = nil;
    self.keypad8Button = nil;
    self.keypad9Button = nil;
    self.keypad0Button = nil;
    self.keypadDelButton = nil;
#if BZ_USE_SOUND
    self.tockPlayer = nil;
#endif
    self.delegate = nil;
#if NS_BLOCKS_AVAILABLE
    self.handler = nil;
#endif
    self.text = nil;
    self.detailText = nil;
    [super dealloc];
}

#if BZ_USE_SOUND
- (void)setTockPlayer:(AVAudioPlayer *)player {
    if (tockPlayer_ != player) {
        if (tockPlayer_) {
            [tockPlayer_ stop];
            [tockPlayer_ release];
            tockPlayer_ = nil;
        }
        if (player) {
            tockPlayer_ = [player retain];
        }
    }
}
#endif

- (IBAction)touchDown:(id)sender {
#if BZ_USE_SOUND
    if (soundEnabled_) {
        [self performSelector:@selector(playTockSound) withObject:nil afterDelay:0];
    }
#endif
}

- (IBAction)touchUp:(id)sender {
    NSInteger tag = [sender tag];
    if (tag >= 0 && tag <= 9) {
        NSString *passcode = currentPasscodeFieldController_.passcode;
        if ([passcode length] < kDefaultPasscodeLength) {
            passcode = [(passcode ?: @"") stringByAppendingFormat:@"%ld", (long)tag];
            currentPasscodeFieldController_.passcode = passcode;
            if ([passcode length] == kDefaultPasscodeLength) {
                [self performSelector:@selector(didEnterPasscode) withObject:nil afterDelay:0.1];
            }
        }
    } else {
        NSString *passcode = currentPasscodeFieldController_.passcode;
        if ([passcode length] > 0) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didEnterPasscode) object:nil];
            passcode = [passcode substringToIndex:([passcode length] - 1)];
            currentPasscodeFieldController_.passcode = passcode;
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // keypadImageView
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BZPasscodeViewController" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:@"keypad" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    keypadImageView_.image = image;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // keypadDelButton
        path = [bundle pathForResource:@"keypad_delete" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
        [keypadDelButton_ setImage:image forState:UIControlStateNormal];
        keypadDelButton_.adjustsImageWhenHighlighted = NO;
    }
    // keypadButtons
    path = [bundle pathForResource:@"keypad_pressed" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    CGPoint point = keypadImageView_.frame.origin;
    CGFloat scale = [image respondsToSelector:@selector(scale)] ? image.scale : 1;
    CGAffineTransform t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-point.x, -point.y), CGAffineTransformMakeScale(scale, scale));
    CGImageRef cgImage = image.CGImage;
    NSArray *keypadButtons = [NSArray arrayWithObjects:keypad1Button_, keypad2Button_, keypad3Button_, keypad4Button_, keypad5Button_, keypad6Button_, keypad7Button_, keypad8Button_, keypad9Button_, keypad0Button_, keypadDelButton_, nil];
    for (UIButton *keypadButton in keypadButtons) {
        CGRect rect = CGRectApplyAffineTransform(keypadButton.frame, t);
        CGImageRef subCgImage = CGImageCreateWithImageInRect(cgImage, rect);
        UIImage *subImage = [UIImage imageWithCGImage:subCgImage];
        CGImageRelease(subCgImage);
        [keypadButton setBackgroundImage:subImage forState:UIControlStateHighlighted];
    }
    self.view.userInteractionEnabled = keypadEnabled_;
#if BZ_USE_SOUND
    // tockPlayer
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    NSURL *fileURL = [NSURL fileURLWithPath:[bundle pathForResource:@"tock" ofType:@"caf"]];
    self.tockPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL] autorelease];
    // XXX: prepareToPlay seems to be ineffectual
    tockPlayer_.volume = 0;
    if ([tockPlayer_ play]) {
        [tockPlayer_ pause];
        tockPlayer_.currentTime = 0;
    }
    tockPlayer_.volume = 0.2;
#endif
    // currentPasscodeFieldController
    self.currentPasscodeFieldController = passcodeFieldController1_;
    [self.view addSubview:currentPasscodeFieldController_.view];
    currentPasscodeFieldController_.text = text_;
    currentPasscodeFieldController_.detailText = detailText_;
    currentPasscodeFieldController_.detailTextHighlighted = detailTextHighlighted_;
}

- (void)viewDidUnload {
    self.passcodeFieldController1 = nil;
    self.passcodeFieldController2 = nil;
    self.currentPasscodeFieldController = nil;
    self.keypadImageView = nil;
    self.keypad1Button = nil;
    self.keypad2Button = nil;
    self.keypad3Button = nil;
    self.keypad4Button = nil;
    self.keypad5Button = nil;
    self.keypad6Button = nil;
    self.keypad7Button = nil;
    self.keypad8Button = nil;
    self.keypad9Button = nil;
    self.keypad0Button = nil;
    self.keypadDelButton = nil;
#if BZ_USE_SOUND
    self.tockPlayer = nil;
#endif
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    if (([systemVersion compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) && ([systemVersion compare:@"5.1" options:NSNumericSearch] == NSOrderedAscending)) {
        // XXX: Required in 5.0.x
        if (self.modalInPopover) {
            self.modalInPopover = YES;
        }
    }
}

#pragma mark - UIViewControllerRotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self]) {
        if ([keyPath isEqualToString:@"keypadEnabled"]) {
            if ([self isViewLoaded]) {
                self.view.userInteractionEnabled = keypadEnabled_;
            }
        } else if ([keyPath isEqualToString:@"text"]) {
            if ([self isViewLoaded]) {
                if (!inDidEnterPasscode_) {
                    currentPasscodeFieldController_.text = text_;
                }
            }
        } else if ([keyPath isEqualToString:@"detailText"]) {
            if ([self isViewLoaded]) {
                if (!inDidEnterPasscode_) {
                    currentPasscodeFieldController_.detailText = detailText_;
                }
            }
        } else if ([keyPath isEqualToString:@"detailTextHighlighted"]) {
            if ([self isViewLoaded]) {
                if (!inDidEnterPasscode_) {
                    currentPasscodeFieldController_.detailTextHighlighted = detailTextHighlighted_;
                }
            }
        } else {
            NSAssert2(NO, @"*** %s: unknown keyPath \"%@\"", __PRETTY_FUNCTION__, keyPath);
        }
    } else {
        NSAssert3(NO, @"*** %s: unknown keyPath \"%@\" of %@", __PRETTY_FUNCTION__, keyPath, object);
    }
}

#pragma mark - Anonymous category

#if BZ_USE_SOUND
- (void)playTockSound {
    if (tockPlayer_.playing) {
        [tockPlayer_ pause];
    }
    tockPlayer_.currentTime = 0;
    [tockPlayer_ play];
}
#endif

- (void)didEnterPasscode {
    inDidEnterPasscode_ = YES;
    NSString *passcode = currentPasscodeFieldController_.passcode;
    BZPasscodeViewControllerResult result;
#if NS_BLOCKS_AVAILABLE
    if (handler_) {
        NSString *text = text_;
        NSString *detailText = detailText_;
        BOOL detailTextHighlighted = detailTextHighlighted_;
        result = self.handler(passcode, &text, &detailText, &detailTextHighlighted);
        if (text_ != text) {
            self.text = text;
        }
        if (detailText_ != detailText) {
            self.detailText = detailText;
        }
        if (detailTextHighlighted_ != detailTextHighlighted) {
            self.detailTextHighlighted = detailTextHighlighted;
        }
    } else
#endif
    if ([delegate_ respondsToSelector:@selector(passcodeViewController:didEnterPasscode:)]) {
        result = [delegate_ passcodeViewController:self didEnterPasscode:passcode];
    } else {
        result = BZPasscodeViewControllerResultInvalid;
    }
    switch (result) {
        case BZPasscodeViewControllerResultInvalid:
            currentPasscodeFieldController_.passcode = nil;
            currentPasscodeFieldController_.text = text_;
            currentPasscodeFieldController_.detailText = detailText_;
            currentPasscodeFieldController_.detailTextHighlighted = detailTextHighlighted_;
            break;
        case BZPasscodeViewControllerResultContinue:
            [self togglePasscodeFields];
            break;
        case BZPasscodeViewControllerResultDone:
        default:
            // do nothing
            break;
    }
    inDidEnterPasscode_ = NO;
}

- (void)togglePasscodeFields {
    BZPasscodeFieldController *nextPasscodeFieldController;
    if ([currentPasscodeFieldController_ isEqual:passcodeFieldController1_]) {
        nextPasscodeFieldController = passcodeFieldController2_;
    } else {
        nextPasscodeFieldController = passcodeFieldController1_;
    }
    CGRect frame = currentPasscodeFieldController_.view.frame;
    CGPoint center, fromCenter, toCenter;
    center = currentPasscodeFieldController_.view.center;
    fromCenter = toCenter = center;
    fromCenter.x += CGRectGetWidth(frame);
    toCenter.x -= CGRectGetWidth(frame);
    // set next
    nextPasscodeFieldController.view.frame = frame;
    nextPasscodeFieldController.view.center = fromCenter;
    [self.view addSubview:nextPasscodeFieldController.view];
    nextPasscodeFieldController.passcode = nil;
    nextPasscodeFieldController.text = text_;
    nextPasscodeFieldController.detailText = detailText_;
    nextPasscodeFieldController.detailTextHighlighted = detailTextHighlighted_;
    // begin animations
    self.view.userInteractionEnabled = NO;
    [UIView beginAnimations:nil context:nextPasscodeFieldController];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.1];
    nextPasscodeFieldController.view.center = center;
    currentPasscodeFieldController_.view.center = toCenter;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // end animations
    [currentPasscodeFieldController_.view removeFromSuperview];
    BZPasscodeFieldController *nextPasscodeFieldController = context;
    self.currentPasscodeFieldController = nextPasscodeFieldController;
    self.view.userInteractionEnabled = YES;
}

@end
