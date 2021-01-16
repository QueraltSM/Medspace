import UIKit
import Firebase
import FirebaseAuth

class SignupVC: UIViewController {

    @IBOutlet weak var repeat_password: UITextField!
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var username: UITextField!
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    func initComponents(){
        db = Database.database().reference()
        self.navigationController?.isNavigationBarHidden = true
        email.textColor = UIColor.black
        password.textColor = UIColor.black
        repeat_password.textColor = UIColor.black
        fullname.textColor = UIColor.black
        username.textColor = UIColor.black
        email.placeHolderColor = UIColor.gray
        password.placeHolderColor = UIColor.gray
        repeat_password.placeHolderColor = UIColor.gray
        fullname.placeHolderColor = UIColor.gray
        username.placeHolderColor = UIColor.gray
    }
    
    func passwordMatched() -> Bool {
        var result = true
        if password.text != repeat_password.text! {
            result = false
            password.setUnderline(color: UIColor.red)
            repeat_password.setUnderline(color: UIColor.red)
            self.showAlert(title: "Error", message: "Password do not match")
        }
        return result
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if (!areEmptyFields() && passwordMatched()) {
            db.child("Users").observeSingleEvent(of: .value, with: { snapshot in
                let enumerator = snapshot.children
                var taken = false
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    let value = rest.value as? NSDictionary
                    let user = value!["username"] as? String ?? ""
                    if user == self.username.text! {
                        taken = true
                        self.showAlert(title: "Error", message: "Username is already taken")
                    }
                }
                if !taken {
                    self.createUser()
                }
            })
        }
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) {(authResult, error) in
            if error != nil {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            } else {
                let uid = authResult!.uid
                self.db = Database.database().reference().child("Users/\(uid)")
                self.db.setValue(["username": self.username.text!, "fullname":self.fullname.text!, "type": "Doctor"])
                self.showAlert(title: "Success!", message: "Your account has been created")
                self.setUserData(fullname: self.fullname.text!, usertype: "Doctor", username: self.username.text!, isUserLoggedIn: true)
            }
        }
    }
    
    func areEmptyFields() -> Bool {
        if !validateTxtfield(username) {
            self.username.setUnderline(color: UIColor.red)
        } else {
            self.username.setUnderline(color: UIColor.white)
        }
        if !validateTxtfield(fullname) {
            self.fullname.setUnderline(color: UIColor.red)
        } else {
            self.fullname.setUnderline(color: UIColor.white)
        }
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
        if !validateTxtfield(repeat_password) {
            self.repeat_password.setUnderline(color: UIColor.red)
        } else {
            self.repeat_password.setUnderline(color: UIColor.white)
        }
        return validateTxtfield(username) && validateTxtfield(fullname) && validateTxtfield(email) && validateTxtfield(password)
            && validateTxtfield(repeat_password)
    }
    
    @IBAction func login(_ sender: Any) {
        presentVC(segue: "LoginVC")
    }
}
