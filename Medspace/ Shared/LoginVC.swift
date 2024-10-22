import UIKit
import Firebase
import FirebaseAuth

var spinningActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
var container: UIView = UIView()

class LoginVC: UIViewController {
    
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var form_title: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var forgot_button: UIButton!
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    func initComponents(){
        db = Database.database().reference().child("Users")
        self.navigationController?.isNavigationBarHidden = true
        email.textColor = UIColor.black
        password.textColor = UIColor.black
        email.placeHolderColor = UIColor.gray
        password.placeHolderColor = UIColor.gray
        login_button.backgroundColor = UIColor.black
    }
    
    func loginUser(){
        self.email.setUnderline(color: UIColor.white)
        self.password.setUnderline(color: UIColor.white)
        self.db.child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let usertype = value?["type"] as? String ?? ""
                let fullname = value?["fullname"] as? String ?? ""
                let username = value?["username"] as? String ?? ""
            self.setUserData(fullname: fullname, usertype: usertype, username: username, isUserLoggedIn: true)
        })
    }
    
    func checkDB() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, error) in
            if let error = error as NSError? {
              switch AuthErrorCode(rawValue: error.code) {
              case .operationNotAllowed:
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: "Email and password accounts are not enabled")
                break
              case .userDisabled:
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: "Account has been disabled")
                break
              case .wrongPassword:
                self.email.setUnderline(color: UIColor.white)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: "Password is invalid")
                break
              case .invalidEmail:
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.white)
                self.showAlert(title: "Error", message: "Email address is malformed")
                break
              default:
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.showAlert(title: "Error", message: error.localizedDescription)
              }
            } else {
                self.loginUser()
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if !validateTxtfield(email) {
            self.email.setUnderline(color: UIColor.red)
        } else {
            self.email.setUnderline(color: UIColor.white)
        }
        if !validateTxtfield(password) {
            self.password.setUnderline(color: UIColor.red)
        } else {
            self.password.setUnderline(color: UIColor.white)
        }
        if (validateTxtfield(email) && validateTxtfield(password)) {
            self.email.setUnderline(color: UIColor.white)
            self.password.setUnderline(color: UIColor.white)
            checkDB()
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Forgot password?", message: "Enter email for reset password", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        }
        let save = UIAlertAction(title: "Send", style: .cancel, handler: { alertAction -> Void in
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
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        alert.addAction(cancel)
        alert.addAction(save)
        alert.preferredAction = save
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        presentVC(segue: "SignupVC")
    }
}
