//
//  SignupVC.swift
//  Medspace
//
//  Created by Queralt Sosa Mompel on 17/8/20.
//  Copyright © 2020 Queralt Sosa Mompel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupVC: UIViewController {

    @IBOutlet weak var fullname: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var email: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var repeat_password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var signup_button: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        customSignupBttn()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func customSignupBttn(){
        signup_button.layer.borderColor = UIColor.black.cgColor
        signup_button.layer.borderWidth = 1
        signup_button.layer.cornerRadius = signup_button.frame.size.height / 2.0
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if (!areEmptyFields()) {
            if (password.text != repeat_password.text!) {
                self.showAlert(title: "Error", message: "Password do not match!")
                password.setUnderline(color: UIColor.red)
                repeat_password.setUnderline(color: UIColor.red)
            } else {
                createUser()
            }
        }
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) {(authResult, error) in
            if error != nil {
                self.fullname.setUnderline(color: UIColor.red)
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.repeat_password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: error!.localizedDescription)
            } else {
                let uid = (authResult?.uid)!
                self.ref.child("Users/\(uid)/Username").setValue(self.fullname.text)
                self.ref.child("Users/\(uid)/Type").setValue("Doctor")
                self.performSegue(withIdentifier: "HomeVC", sender: nil)
            }
        }
    }
    
    func areEmptyFields() -> Bool {
        var result = false
        if ((fullname.text?.isEmpty)!) {
            fullname.setUnderline(color: UIColor.red)
            result = true
        }
        if ((email.text?.isEmpty)!) {
            email.setUnderline(color: UIColor.red)
            result = true
        }
        if ((password.text?.isEmpty)!) {
            password.setUnderline(color: UIColor.red)
            result = true
        }
        if ((repeat_password.text?.isEmpty)!) {
            repeat_password.setUnderline(color: UIColor.red)
            result = true
        }
        return result
    }
}
