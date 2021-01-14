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
        db = Database.database().reference()
        signup_button.layer.cornerRadius = signup_button.frame.size.height / 2.0
        email.setUnderline(color: UIColor.darkGray)
        password.setUnderline(color: UIColor.darkGray)
        email.textColor = UIColor.black
        password.textColor = UIColor.black
        fullname.textColor = UIColor.black
        username.textColor = UIColor.black
        email.placeHolderColor = UIColor.black
        password.placeHolderColor = UIColor.black
        fullname.placeHolderColor = UIColor.black
        username.placeHolderColor = UIColor.black
        
    }
    
    func passwordMatched() -> Bool {
        var result = true
        if password.text != repeat_password.text! {
            result = false
            password.setUnderline(color: UIColor.red)
            repeat_password.setUnderline(color: UIColor.red)
            self.showAlert(title: "Error", message: "Password do not match!")
        }
        return result
    }
    
    @IBAction func createAccount(_ sender: Any) {
        print("createAccount")
        print(areEmptyFields())
        print(passwordMatched())
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
                self.fullname.setUnderline(color: UIColor.red)
                self.email.setUnderline(color: UIColor.red)
                self.password.setUnderline(color: UIColor.red)
                self.repeat_password.setUnderline(color: UIColor.red)
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
    
    func notEmpty(result:Bool, textfield: UITextField) -> Bool {
        var empty = false
        var color = UIColor.black
        if !result {
            color = UIColor.red
            empty = true
        }
        textfield.setUnderline(color: color)
        return empty
    }
    
    func areEmptyFields() -> Bool {
        return notEmpty(result: validateTxtfield(username), textfield: username) && notEmpty(result: validateTxtfield(fullname), textfield: fullname)
        && notEmpty(result: validateTxtfield(email), textfield: email) && notEmpty(result: validateTxtfield(password), textfield: password)
        && notEmpty(result: validateTxtfield(repeat_password), textfield: repeat_password)
    }
    
    @IBAction func login(_ sender: Any) {
        presentVC(segue: "LoginVC")
    }
}
