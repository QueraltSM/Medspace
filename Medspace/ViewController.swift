//
//  ViewController.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 16/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performSegue(withIdentifier: "LoginVC", sender: nil)
        }
    }
}

extension UITextField {
    func setBorderColor(color: UIColor) {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.masksToBounds = true
    }
}

/*
 Thanks to this library for floating textField:
 https://github.com/hasnine/iOSUtilitiesSource
 */

enum placeholderDirection: String {
    case placeholderUp = "up"
    case placeholderDown = "down"
    
}
public class IuFloatingTextFiledPlaceHolder: UITextField {
    var enableMaterialPlaceHolder : Bool = true
    var placeholderAttributes = NSDictionary()
    var lblPlaceHolder = UILabel()
    var defaultFont = UIFont()
    var difference: CGFloat = 22.0
    var directionMaterial = placeholderDirection.placeholderUp
    var isUnderLineAvailabe : Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize ()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize ()
    }
    
    func setUnderline(color: UIColor) {
        let underLine = UIImageView()
        underLine.backgroundColor = color
        underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width : self.frame.size.width, height : 1)
        underLine.layer.cornerRadius = self.frame.size.height / 2.0
        underLine.clipsToBounds = true
        self.addSubview(underLine)
    }
    
    func Initialize(){
        self.clipsToBounds = false
        self.addTarget(self, action: #selector(IuFloatingTextFiledPlaceHolder.textFieldDidChange), for: .editingChanged)
        self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: true)
        if isUnderLineAvailabe {
            setUnderline(color: UIColor.darkGray)
        }
        defaultFont = self.font!
        
    }
    @IBInspectable var placeHolderColor: UIColor? = UIColor.black {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder! as String ,
                                                            attributes:[NSAttributedString.Key.foregroundColor: placeHolderColor!])
        }
    }
    override public var placeholder:String?  {
        didSet {
            //  NSLog("placeholder = \(placeholder)")
        }
        willSet {
            let atts  = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: UIFont.labelFontSize] as! [NSAttributedString.Key : Any]
            self.attributedPlaceholder = NSAttributedString(string: newValue!, attributes:atts)
            self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
        }
        
    }
    override public var attributedText:NSAttributedString?  {
        didSet {
            //  NSLog("text = \(text)")
        }
        willSet {
            if (self.placeholder != nil) && (self.text != "")
            {
                let string = NSString(string : self.placeholder!)
                self.placeholderText(string)
            }
            
        }
    }
    @objc func textFieldDidChange(){
        if self.enableMaterialPlaceHolder {
            if (self.text == nil) || (self.text?.count)! > 0 {
                self.lblPlaceHolder.alpha = 1
                self.attributedPlaceholder = nil
                self.lblPlaceHolder.textColor = self.placeHolderColor
                self.lblPlaceHolder.frame.origin.x = 0 ////\\
                let fontSize = self.font!.pointSize;
                self.lblPlaceHolder.font = UIFont.init(name: (self.font?.fontName)!, size: fontSize-3)
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
                if (self.text == nil) || (self.text?.count)! <= 0 {
                    self.lblPlaceHolder.font = self.defaultFont
                    self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x+10, y : 0, width :self.frame.size.width, height : self.frame.size.height)
                }
                else {
                    if self.directionMaterial == placeholderDirection.placeholderUp {
                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : -self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }else{
                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }
                    
                }
            }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    func enableMaterialPlaceHolder(enableMaterialPlaceHolder: Bool){
        self.enableMaterialPlaceHolder = enableMaterialPlaceHolder
        self.lblPlaceHolder = UILabel()
        self.lblPlaceHolder.frame = CGRect(x: 0, y : 0, width : 0, height :self.frame.size.height)
        self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 10)
        self.lblPlaceHolder.alpha = 0
        self.lblPlaceHolder.clipsToBounds = true
        self.addSubview(self.lblPlaceHolder)
        self.lblPlaceHolder.attributedText = self.attributedPlaceholder
        //self.lblPlaceHolder.sizeToFit()
    }
    func placeholderText(_ placeholder: NSString){
        let atts  = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.labelFontSize] as [NSAttributedString.Key : Any]
        self.attributedPlaceholder = NSAttributedString(string: placeholder as String , attributes:atts)
        self.enableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
    }
    override public func becomeFirstResponder()->(Bool){
        let returnValue = super.becomeFirstResponder()
        return returnValue
    }
    override public func resignFirstResponder()->(Bool){
        let returnValue = super.resignFirstResponder()
        return returnValue
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
