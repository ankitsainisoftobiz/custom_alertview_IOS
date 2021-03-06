//
//  CustomAlertView.swift
//  SwifPro
//
//  Created by Ankit Saini on 4/6/16.
//  Copyright © 2016 Mr_X. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    func customAlertViewButtonTouchUpInside(alertView: CustomAlertView, buttonIndex: Int)
}

enum buttonDirection {
    case buttonDirectionHorizontal
    case buttonDirectionVertical
}

enum buttonStyle {
    case buttonStyleDefault
    case buttonStyleInnerView
}

enum onTouchDismiss {
    case touchDismissNO
    case touchDismissYES
}

class CustomAlertView: UIView {
    
    //MARK:- Properties
    var buttonWIDTH: CGFloat = 0
    
    var buttonHeight: CGFloat = 50
    var buttonsDividerHeight: CGFloat = 1
    var cornerRadius: CGFloat = 7
    var buttonMargin: Int = 10
    
    var useMotionEffects: Bool = true
    var motionEffectExtent: Int = 10
    
    private var alertView: UIView!
    var containerView: UIView!
    
    var buttonTitles: [String]? = ["Close"]
    var buttonIcons: [String]?
    var showCloseButton:Bool?
    
    var buttonColor: UIColor?
    var buttonColorHighlighted: UIColor?
    var buttonBGColor: [String]? = []
    var alertBGColor: [String]? = ["#EFEEEC", "#EFEEEC", "#EFEEEC"]
    var showButtonRadius: Bool = false
    var alertButtonStyle = buttonStyle.buttonStyleDefault
    var alertDismiss = onTouchDismiss.touchDismissNO
    
    var btnDismiss: UIButton?
    
    
    var alertButtonDirection = buttonDirection.buttonDirectionHorizontal
    
    
    weak var delegate: CustomAlertViewDelegate?
    var onButtonTouchUpInside: ((alertView: CustomAlertView, buttonIndex: Int) -> Void)?
    
    //MARK:- Initialisation
    
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        setObservers()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setObservers()
        
    }
    
    //MARK:- Create the dialog view and animate its opening
    internal func show() {
        if showCloseButton == false {
            buttonTitles = []
        }
        addDismissTouch()
        show(nil)
    }
    
    internal func show(completion: ((Bool) -> Void)?) {
        alertView = createAlertView()
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.addSubview(alertView)
        
        // Attach to the top most window
        switch (UIApplication.sharedApplication().statusBarOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 270 / 180))
            
        case UIInterfaceOrientation.LandscapeRight:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 90 / 180))
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 180 / 180))
            
        default:
            break
        }
        
        self.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        UIApplication.sharedApplication().windows.first?.addSubview(self)
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.alertView.layer.opacity = 1
            self.alertView.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: completion)
    }
    
    //MARK:- Close the alertView, remove views
    
    internal func addDismissTouch() -> Void {
        if alertDismiss == onTouchDismiss.touchDismissYES {
            if btnDismiss == nil {
                btnDismiss = UIButton.init(frame: self.bounds)
                btnDismiss!.addTarget(self, action: #selector(dismissClicked(_:)), forControlEvents: .TouchUpInside)
                self.insertSubview(btnDismiss!, atIndex: 0)
            }
            
        }
    }
    
    func dismissClicked(sender: UIButton) -> Void {
        close()
    }
    
    internal func close() {
        close(nil)
    }
    
    internal func close(completion: ((Bool) -> Void)?) {
        let currentTransform = alertView.layer.transform
        
        let startRotation = alertView.valueForKeyPath("layer.transform.rotation.z")!.floatValue
        let rotation = CATransform3DMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI * 270 / 180), 0, 0, 0)
        
        alertView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        alertView.layer.opacity = 1
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.alertView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
            self.alertView.layer.opacity = 0
            }, completion: { (finished: Bool) in
                for view in self.subviews as [UIView] {
                    view.removeFromSuperview()
                }
                
                self.removeFromSuperview()
                completion?(finished)
        })
    }
    
    // Enables or disables the specified button
    // Should be used after the alert view is displayed
    internal func setButtonEnabled(enabled: Bool, buttonName: String) {
        for subview in alertView.subviews as [UIView] {
            if subview is UIButton {
                let button = subview as! UIButton
                
                if button.currentTitle == buttonName {
                    button.enabled = enabled
                    break
                }
            }
        }
    }
    
    // Observe orientation and keyboard changes
    private func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomAlertView.deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomAlertView.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomAlertView.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    // Create the containerView
    private func createAlertView() -> UIView {
        if containerView == nil {
            //containerView = UIView(frame: CGRectMake(0, 0, 300, 150))
            containerView = UIView(frame: CGRectMake(0, 0, 300, 1))
        }
        
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        let view = UIView(frame: CGRectMake(
            (screenSize.width - dialogSize.width) / 2,
            (screenSize.height - dialogSize.height) / 2,
            dialogSize.width,
            dialogSize.height
            ))
        
        // Style the alertView to match the iOS7 UIAlertView
        view.layer.insertSublayer(generateGradient(view.bounds), atIndex: 0)
        view.layer.cornerRadius = cornerRadius
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha:1).CGColor
        
        view.layer.shadowRadius = cornerRadius + 5
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).CGPath
        
        view.layer.opacity = 0.5
        view.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        view.layer.masksToBounds = true
        
        // Apply motion effects
        if useMotionEffects {
            applyMotionEffects(view)
        }
        
        // Add subviews
        view.addSubview(generateButtonsDivider(view.bounds))
        view.addSubview(containerView)
        self.addButtonsToView(view)
        
        return view
    }
    
    // Generate the view for the buttons divider
    private func generateButtonsDivider(bounds: CGRect) -> UIView {
        
        switch alertButtonDirection {
        case .buttonDirectionHorizontal:
            let divider = UIView(frame: CGRectMake(
                0,
                bounds.size.height - buttonHeight - buttonsDividerHeight,
                bounds.size.width,
                buttonsDividerHeight
                ))
            
            divider.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
            
            return divider
            break
        default:
            break
        }
        
        return UIView()
    }
    
    // Generate the gradient layer of the alertView
    private func generateGradient(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        
        let arrColors: NSMutableArray = []
        
        for j in alertBGColor! {
            arrColors.addObject(UIColor.init(hexString:j).CGColor)
        }
        
        gradient.colors = arrColors as [AnyObject]
        //        gradient.colors = [
        //            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).CGColor,
        //            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha:1).CGColor,
        //            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha:1).CGColor
        //        ]
        
        return gradient
    }
    
    //MARK: Add the buttons to the containerView
    private func addButtonsToView(container: UIView) {
        if buttonTitles == nil || buttonTitles?.count == 0 {
            return
        }
        
        let buttonWidth = buttonWIDTH > 0 ? buttonWIDTH : container.bounds.size.width / CGFloat(buttonTitles!.count)
        
        //
        //create scroll view to add button in case button's height total is more than screen size
        //
        let scrScrollView: UIScrollView = UIScrollView.init()
        scrScrollView.frame = CGRectMake(0, container.bounds.size.height - buttonHeight, container.frame.size.width, buttonHeight)
        
        var contentWidth:CGFloat = container.frame.size.width
        var contentHeight:CGFloat = buttonHeight
        
        //Define content size of scrollview
        switch alertButtonDirection {
        case .buttonDirectionVertical:
            //let total:CGFloat = (buttonHeight * CGFloat((buttonTitles?.count)!)) + (CGFloat(buttonMargin) * (CGFloat((buttonTitles?.count)!+1)))
            let scrollViewHeight = container.bounds.size.height - containerView.frame.size.height
            
            
            
            scrScrollView.frame = CGRectMake(0, self.calculateDialogSize().height - scrollViewHeight, scrScrollView.frame.size.width, scrollViewHeight)
            //scrScrollView.backgroundColor = UIColor.redColor()
            break
        default:
            break
        }
        
        var startY:CGFloat = CGFloat(buttonMargin)
        
        
        for buttonIndex in 0...(buttonTitles!.count - 1) {
            //let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            let button = UIButton.init()
            
            switch alertButtonDirection {
            case .buttonDirectionHorizontal:
                
                let xCo = CGFloat(buttonIndex) * CGFloat(buttonWidth)
                
                if alertButtonStyle == buttonStyle.buttonStyleInnerView {
                    button.frame = CGRectMake(
                        xCo+5,
                        5,
                        buttonWidth-10,
                        buttonHeight-10
                    )
                }
                else{
                    button.frame = CGRectMake(
                        xCo,
                        0,
                        buttonWidth,
                        buttonHeight
                    )
                }
                
                contentWidth = buttonWidth * CGFloat((buttonTitles?.count)!) + buttonWidth/2 + 15.0
                break
            case .buttonDirectionVertical:
                
                button.frame = CGRectMake(10, startY, container.bounds.size.width-20, buttonHeight)
                startY = startY + buttonHeight + CGFloat(buttonMargin)
                contentHeight = startY
                break
            }
            
            
            
            
            button.tag = buttonIndex
            button.addTarget(self, action: #selector(CustomAlertView.buttonTouchUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            let colorNormal = buttonColor != nil ? buttonColor : button.tintColor
            let colorHighlighted = buttonColorHighlighted != nil ? buttonColorHighlighted : colorNormal.colorWithAlphaComponent(0.5)
            
            button.setTitle(buttonTitles![buttonIndex], forState: UIControlState.Normal)
            button.setTitleColor(colorNormal, forState: UIControlState.Normal)
            button.setTitleColor(colorHighlighted, forState: UIControlState.Highlighted)
            button.setTitleColor(colorHighlighted, forState: UIControlState.Disabled)
            
            if showButtonRadius {
                button.layer.cornerRadius = cornerRadius
            }
            
            if buttonBGColor?.count>0 {
                button.backgroundColor = buttonIndex >= buttonBGColor?.count ? UIColor.clearColor() : UIColor.init(hexString: buttonBGColor![buttonIndex])
            }
            
            if buttonIcons != nil {
                if buttonIcons?.count > 0 {
                    if buttonIndex < buttonIcons?.count {
                        button.setImage(UIImage(named:buttonIcons![buttonIndex] ), forState: .Normal)
                    }
                    button.contentHorizontalAlignment = .Left
                    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
                    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
                }
            }
            //container.addSubview(button)
            scrScrollView.addSubview(button)
            container.addSubview(scrScrollView)
            
            // Show a divider between buttons
            if buttonIndex > 0 {
                switch alertButtonDirection {
                case .buttonDirectionHorizontal:
                    if alertButtonStyle == buttonStyle.buttonStyleDefault {
                        
                        let verticalLineView = UIView(frame: CGRectMake(
                            button.bounds.size.width * CGFloat(buttonIndex),
                            0,//container.bounds.size.height - buttonHeight - buttonsDividerHeight
                            buttonsDividerHeight,
                            buttonHeight
                            ))
                        //container.bounds.size.width / CGFloat(buttonTitles!.count) * CGFloat(buttonIndex)
                        verticalLineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
                        
                        scrScrollView.addSubview(verticalLineView)
                        //container.addSubview(verticalLineView)
                    }
                    
                    break
                default:
                    break
                }
                
            }
        }
        
        //Define content size of scrollview
        
        scrScrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
    }
    
    // Calculate the size of the dialog
    private func calculateDialogSize() -> CGSize {
        switch alertButtonDirection {
        case .buttonDirectionHorizontal:
            return CGSizeMake(
                containerView.frame.size.width,
                containerView.frame.size.height + buttonHeight + buttonsDividerHeight
            )
        case .buttonDirectionVertical:
            var height = (buttonHeight * CGFloat((buttonTitles?.count)!))+(CGFloat(((buttonTitles?.count)! - 1)) * CGFloat(buttonMargin))
            height = containerView.frame.size.height + height + CGFloat(buttonMargin*2)
            height = height>self.calculateScreenSize().height ? self.calculateScreenSize().height : height
            return CGSizeMake(
                containerView.frame.size.width,
                height
            )
        }
        
    }
    
    // Calculate the size of the screen
    private func calculateScreenSize() -> CGSize {
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        if orientationIsLandscape() {
            return CGSizeMake(height, width)
        } else {
            return CGSizeMake(width, height)
        }
    }
    
    // Add motion effects
    private func applyMotionEffects(view: UIView) {
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -motionEffectExtent
        horizontalEffect.maximumRelativeValue = +motionEffectExtent
        
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -motionEffectExtent
        verticalEffect.maximumRelativeValue = +motionEffectExtent
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalEffect, verticalEffect]
        
        view.addMotionEffect(motionEffectGroup)
    }
    
    // Whether the UI is in landscape mode
    private func orientationIsLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    // Call the delegates
    internal func buttonTouchUpInside(sender: UIButton!) {
        delegate?.customAlertViewButtonTouchUpInside(self, buttonIndex: sender.tag)
        onButtonTouchUpInside?(alertView: self, buttonIndex: sender.tag)
    }
    
    // Handle device orientation changes
    internal func deviceOrientationDidChange(notification: NSNotification) {
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let startRotation = self.valueForKeyPath("layer.transform.rotation.z")!.floatValue
        
        var rotation: CGAffineTransform
        
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI * 270 / 180))
            break
            
        case UIInterfaceOrientation.LandscapeRight:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI * 90 / 180))
            break
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI * 180 / 180))
            break
            
        default:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + 0)
            break
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.transform = rotation
            }, completion: nil)
        
        // Fix errors caused by being rotated one too many times
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            let endInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            if interfaceOrientation != endInterfaceOrientation {
                // TODO: user moved phone again before than animation ended: rotation animation can introduce errors here
            }
        })
    }
    
    // Handle keyboard show changes
    internal func keyboardWillShow(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        
        if orientationIsLandscape() {
            keyboardSize = CGSize(width: keyboardSize.height, height: keyboardSize.width)
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.frame = CGRectMake((
                screenSize.width - dialogSize.width) / 2,
                (screenSize.height - keyboardSize.height - dialogSize.height) / 2,
                dialogSize.width,
                dialogSize.height
            )
            }, completion: nil)
    }
    
    // Handle keyboard hide changes
    internal func keyboardWillHide(notification: NSNotification) {
        let screenSize = self.calculateScreenSize()
        let dialogSize = self.calculateDialogSize()
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            self.alertView.frame = CGRectMake(
                (screenSize.width - dialogSize.width) / 2,
                (screenSize.height - dialogSize.height) / 2,
                dialogSize.width,
                dialogSize.height
            )
            }, completion: nil)
    }
    
    
    //MARK:- Deallocate
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
}


extension UIColor {
    convenience init(hexString:String) {
        let hexString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner            = NSScanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}


