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
        signup_button.layer.borderColor = UIColor.black.cgColor
        signup_button.layer.borderWidth = 1
        signup_button.layer.cornerRadius = signup_button.frame.size.height / 2.0
        repeat_password.setUnderline(color: UIColor.black)
        email.setUnderline(color: UIColor.black)
        password.setUnderline(color: UIColor.black)
        fullname.setUnderline(color: UIColor.black)
        username.setUnderline(color: UIColor.black)
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
        if (!areEmptyFields() && passwordMatched()) {
            Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
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
    
    func areEmptyFields() -> Bool {
        var result = false
        if username.text!.isEmpty {
            username.setUnderline(color: UIColor.red)
            result = true
        } else {
            username.setUnderline(color: UIColor.black)
        }
        if username.text!.contains(" ") {
            username.setUnderline(color: UIColor.red)
            result = true
            self.showAlert(title: "Error", message: "Username can not contain spaces")
        } else {
            username.setUnderline(color: UIColor.black)
        }
        if fullname.text!.isEmpty {
            fullname.setUnderline(color: UIColor.red)
            result = true
        } else {
            fullname.setUnderline(color: UIColor.black)
        }
        if email.text!.isEmpty {
            email.setUnderline(color: UIColor.red)
            result = true
        } else {
            email.setUnderline(color: UIColor.black)
        }
        if password.text!.isEmpty {
            password.setUnderline(color: UIColor.red)
            result = true
        } else {
            password.setUnderline(color: UIColor.black)
        }
        if repeat_password.text!.isEmpty {
            repeat_password.setUnderline(color: UIColor.red)
            result = true
        } else {
            repeat_password.setUnderline(color: UIColor.black)
        }
        return result
    }
}
