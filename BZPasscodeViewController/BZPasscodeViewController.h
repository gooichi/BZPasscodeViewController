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

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIViewController.h>

#if BZ_USE_SOUND
@class AVAudioPlayer;
#endif
@class UIButton, UIImageView, UILabel, UITextField;
@class BZPasscodeFieldController;
@protocol BZPasscodeViewControllerDelegate;

enum {
    BZPasscodeViewControllerResultInvalid,
    BZPasscodeViewControllerResultContinue,
    BZPasscodeViewControllerResultDone
};
typedef NSInteger BZPasscodeViewControllerResult;

#if NS_BLOCKS_AVAILABLE
typedef BZPasscodeViewControllerResult (^BZPasscodeViewControllerHandler)(NSString *passcode, NSString **text, NSString **detailText, BOOL *detailTextHighlighted);
#endif

@interface BZPasscodeViewController : UIViewController {
    BZPasscodeFieldController   *passcodeFieldController1_;
    BZPasscodeFieldController   *passcodeFieldController2_;
    BZPasscodeFieldController   *currentPasscodeFieldController_;
    UIImageView                 *keypadImageView_;
    UIButton                    *keypad1Button_;
    UIButton                    *keypad2Button_;
    UIButton                    *keypad3Button_;
    UIButton                    *keypad4Button_;
    UIButton                    *keypad5Button_;
    UIButton                    *keypad6Button_;
    UIButton                    *keypad7Button_;
    UIButton                    *keypad8Button_;
    UIButton                    *keypad9Button_;
    UIButton                    *keypad0Button_;
    UIButton                    *keypadDelButton_;
    BOOL                        keypadEnabled_;
#if BZ_USE_SOUND
    AVAudioPlayer               *tockPlayer_;
    BOOL                        soundEnabled_;
#endif
    id <BZPasscodeViewControllerDelegate> delegate_;
#if NS_BLOCKS_AVAILABLE
    BZPasscodeViewControllerHandler handler_;
#endif
    NSString                    *text_;
    NSString                    *detailText_;
    BOOL                        detailTextHighlighted_;
    BOOL                        inDidEnterPasscode_;
}
@property(nonatomic,retain) IBOutlet BZPasscodeFieldController *passcodeFieldController1;
@property(nonatomic,retain) IBOutlet BZPasscodeFieldController *passcodeFieldController2;
@property(nonatomic,readonly,assign) BZPasscodeFieldController *currentPasscodeFieldController;
@property(nonatomic,retain) IBOutlet UIImageView *keypadImageView;
@property(nonatomic,retain) IBOutlet UIButton *keypad1Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad2Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad3Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad4Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad5Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad6Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad7Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad8Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad9Button;
@property(nonatomic,retain) IBOutlet UIButton *keypad0Button;
@property(nonatomic,retain) IBOutlet UIButton *keypadDelButton;
@property(nonatomic,getter=isKeypadEnabled) BOOL keypadEnabled;
#if BZ_USE_SOUND
@property(nonatomic,getter=isSoundEnabled) BOOL soundEnabled;
#endif
@property(nonatomic,assign) id <BZPasscodeViewControllerDelegate> delegate;
#if NS_BLOCKS_AVAILABLE
@property(nonatomic,copy) BZPasscodeViewControllerHandler handler;
#endif
@property(nonatomic,copy) NSString *text;
@property(nonatomic,copy) NSString *detailText;
@property(nonatomic,getter=isDetailTextHighlighted) BOOL detailTextHighlighted;

+ (CGSize)defaultContentSizeForView;

- (IBAction)touchDown:(id)sender;
- (IBAction)touchUp:(id)sender;

@end

@protocol BZPasscodeViewControllerDelegate <NSObject>
@required
- (BZPasscodeViewControllerResult)passcodeViewController:(BZPasscodeViewController *)controller didEnterPasscode:(NSString *)passcode;
@end

@interface BZPasscodeFieldController : UIViewController {
    UITextField         *passcode0Field_;
    UITextField         *passcode1Field_;
    UITextField         *passcode2Field_;
    UITextField         *passcode3Field_;
    UILabel             *textLabel_;
    UILabel             *detailTextLabel_;
    UIImageView         *detailTextBackground_;
    NSString            *passcode_;
    NSString            *text_;
    NSString            *detailText_;
    BOOL                detailTextHighlighted_;
}
@property(nonatomic,retain) IBOutlet UITextField *passcode0Field;
@property(nonatomic,retain) IBOutlet UITextField *passcode1Field;
@property(nonatomic,retain) IBOutlet UITextField *passcode2Field;
@property(nonatomic,retain) IBOutlet UITextField *passcode3Field;
@property(nonatomic,retain) IBOutlet UILabel *textLabel;
@property(nonatomic,retain) IBOutlet UILabel *detailTextLabel;
@property(nonatomic,retain) IBOutlet UIImageView *detailTextBackground;

@end
