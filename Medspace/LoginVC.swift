//
//  LoginVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 17/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var email: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var login_button: UIButton!
    var blue: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customLoginBttn()
    }
    
    func customLoginBttn(){
        login_button.layer.borderColor = UIColor.black.cgColor
        login_button.layer.borderWidth = 1
        login_button.layer.cornerRadius = login_button.frame.size.height / 2.0
    }
    
    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                if ((result?.isEmailVerified)!) {
                    self.performSegue(withIdentifier: "HomeVC", sender: nil)
                } else {
                    self.showAlert(title: "Couldn't sign you in", message: "Please check your mailbox to verify your account")
                }
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Forgot password?", message: "Enter email for reset password", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        let save = UIAlertAction(title: "Send", style: .default, handler: { alertAction -> Void in
            if let textField = alert.textFields?[0] {
                if textField.text!.count > 0 {
                    Auth.auth().sendPasswordReset(withEmail: textField.text!) { error in
                        var title = "Success!"
                        var message = "Email has been sent. Check your mailbox to reset your password"
                        if error != nil {
                            title = "Error"
                            message = "Email can not be sent. Please try again"
                        }
                        self.showAlert(title:title, message: message)
                    }
                    
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        alert.addAction(cancel)
        alert.addAction(save)
        alert.preferredAction = save
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
