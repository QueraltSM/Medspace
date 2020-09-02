import UIKit
import Firebase
import FirebaseAuth

var spinningActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
var container: UIView = UIView()

class LoginVC: UIViewController {
    
    @IBOutlet weak var email: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var login_button: UIButton!
    
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
                        let usertype = value?["type"] as? String ?? ""
                        let fullname = value?["fullname"] as? String ?? ""
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
}
