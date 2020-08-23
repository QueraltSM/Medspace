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
    var spinningActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customLoginBttn()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func customLoginBttn(){
        login_button.layer.borderColor = UIColor.black.cgColor
        login_button.layer.borderWidth = 1
        login_button.layer.cornerRadius = login_button.frame.size.height / 2.0
    }
    
    func stopAnimation() {
        self.spinningActivityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.container.removeFromSuperview()
    }
    
    func setActivityIndicator() {
        let window = UIApplication.shared.keyWindow
        container.frame = UIScreen.main.bounds
        container.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.6)
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor.init(hexString: "#03264o")
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 40
        spinningActivityIndicator.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
        spinningActivityIndicator.hidesWhenStopped = true
        spinningActivityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        spinningActivityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(spinningActivityIndicator)
        container.addSubview(loadingView)
        window!.addSubview(container)
        spinningActivityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.setActivityIndicator()
                Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
                        let value = snapshot.value as? NSDictionary
                        let usertype = value?["Type"] as? String ?? ""
                        let fullname = value?["Fullname"] as? String ?? ""
                        UserDefaults.standard.set(usertype, forKey: "usertype")
                        UserDefaults.standard.set(fullname, forKey: "fullname")
                        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                        self.stopAnimation()
                        self.performSegue(withIdentifier: "HomeVC", sender: nil)
                    })
                
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
