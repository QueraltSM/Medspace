import UIKit
import Firebase
import FirebaseAuth

class SignupVC: UIViewController {

    @IBOutlet weak var fullname: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var email: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var repeat_password: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var username: IuFloatingTextFiledPlaceHolder!
    @IBOutlet weak var signup_button: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false, gray: false)
        ref = Database.database().reference()
        signup_button.layer.borderColor = UIColor.black.cgColor
        signup_button.layer.borderWidth = 1
        signup_button.layer.cornerRadius = signup_button.frame.size.height / 2.0
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
                self.ref.child("Users/\(uid)/username").setValue(self.username.text)
                self.ref.child("Users/\(uid)/fullname").setValue(self.fullname.text)
                self.ref.child("Users/\(uid)/type").setValue("Doctor")
                self.setUserData(fullname: self.fullname.text!, usertype: "Doctor", username: self.username.text!, isUserLoggedIn: true)
            }
        }
    }
    
    func areEmptyFields() -> Bool {
        var result = false
        if username.text!.isEmpty {
            username.setUnderline(color: UIColor.red)
            result = true
        }
        if username.text!.contains(" ") {
            username.setUnderline(color: UIColor.red)
            result = true
            self.showAlert(title: "Error", message: "Username can not contain spaces")
        }
        if fullname.text!.isEmpty {
            fullname.setUnderline(color: UIColor.red)
            result = true
        }
        if email.text!.isEmpty {
            email.setUnderline(color: UIColor.red)
            result = true
        }
        if password.text!.isEmpty {
            password.setUnderline(color: UIColor.red)
            result = true
        }
        if repeat_password.text!.isEmpty {
            repeat_password.setUnderline(color: UIColor.red)
            result = true
        }
        return result
    }
}
