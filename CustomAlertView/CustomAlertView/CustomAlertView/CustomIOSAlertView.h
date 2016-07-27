//
//  CustomIOSAlertView.h
//  GiveAwayAday
//
//  Created by softobiz on 10/20/15.
//  Developers: Ankit Saini , Harsh Thakur
//  Copyright © 2015 softobiz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ShowButtonsDirectionHorizontal = 0,
    ShowButtonsDirectionVertical
}ShowButtonsDirection;

typedef enum {
    ShowButtonRadiusYES = 0,
    ShowButtonRadiusNO
}ShowButtonRadius;

typedef enum {
    ShowCustomFrameButtonNO = 0,
    ShowCustomFrameButtonYES
}ShowCustomFrameButton;

@protocol CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomIOSAlertView : UIView<CustomIOSAlertViewDelegate>
{
    UILabel *lblTitle,*lblMessage;
    ShowButtonsDirection buttonOrientation;// Default is horizontal
    ShowButtonRadius    showButtonRadius;
}
@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, assign) id<CustomIOSAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, strong) NSArray *buttonTextColors;
@property (nonatomic, strong) NSArray *buttonBackgroundColors;
@property (nonatomic, strong) UIColor   *alertViewBgColor;// Background color of alert view

@property (nonatomic, assign) BOOL useMotionEffects;

@property (nonatomic,strong)  NSString *strTitle;//set title in alert view
@property (nonatomic,strong)  NSString *strMessage;//set message in alert view
@property (nonatomic,strong)  UIImage  *imgName;//set background image of alertview

@property (nonatomic, assign) BOOL      showCloseButton;
@property (nonatomic, assign) ShowButtonsDirection buttonOrientation;// Default is horizontal
@property (nonatomic, assign) ShowButtonRadius    showButtonRadius;
@property (nonatomic, assign) ShowCustomFrameButton    showCustomFrameButton;


@property (copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex) ;

- (id)init;

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
