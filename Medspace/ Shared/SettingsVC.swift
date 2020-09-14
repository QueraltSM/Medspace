import UIKit
import Firebase
import FirebaseAuth

class SettingsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var delete_box: UIView!
    @IBOutlet weak var changeNamesBox: UIView!
    @IBOutlet weak var changePassButton: UIButton!
    @IBOutlet weak var account_name: UITextField!
    @IBOutlet weak var full_name: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: true, gray: false)
        delete_box.setBorder()
        changeNamesBox.setBorder()
        ref = Database.database().reference()
        account_name.delegate = self
        full_name.delegate = self
        enableDeleteButton(isEnabled: true, borderColor: UIColor.init(hexString: "#900603"), titleColor: UIColor.init(hexString: "#900603"))
        changePassButton.layer.borderColor = UIColor.init(hexString: "#287AA9").cgColor
        changePassButton.layer.cornerRadius = 10
        changePassButton.layer.borderWidth = 2.0
        changePassButton.setTitleColor(UIColor.init(hexString: "#287AA9"), for: .normal)
        if usertype! == "Admin" {
            enableDeleteButton(isEnabled: false, borderColor: UIColor.lightGray, titleColor: UIColor.lightGray)
        }
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            self.account_name.text = value?["username"] as? String ?? ""
            self.full_name.text = value?["fullname"] as? String ?? ""
            self.account_name.textColor = UIColor.gray
            self.full_name.textColor = UIColor.gray
        })
    }
    
    func enableDeleteButton(isEnabled: Bool, borderColor: UIColor, titleColor: UIColor) {
        deleteButton.isEnabled = isEnabled
        deleteButton.layer.borderColor = borderColor.cgColor
        deleteButton.setTitleColor(titleColor, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderWidth = 2.0
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
    
    @IBAction func changePassword(_ sender: Any) {
        let alert = UIAlertController(title: "Change password?", message: "Enter new password", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let save = UIAlertAction(title: "Done", style: .default, handler: { alertAction -> Void in
            if let textField = alert.textFields?[0] {
                if textField.text!.count > 0 {
                    Auth.auth().currentUser!.updatePassword(to: "x") { error in
                        var title = "Success!"
                        var message = "Password has been updated"
                        if error != nil {
                            title = "Error"
                            message = "Password can not be updated. Please try again"
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
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want to delete your account?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.removeUserPosts(path: "Cases")
            self.removeUserPosts(path: "Discussions")
            self.removeUserPosts(path: "Researches")
            Auth.auth().currentUser!.delete { error in
                if error == nil {
                    self.showAlert(title: "Goodbye doctor!", message: "We hope to see you again.\nStay hungry!")
                    self.presentVC(segue: "LoginVC")
                } else {
                    self.showAlert(title: "Error", message: "There was an error deleting your account. Please try again")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeUserPosts(path: String) {
        ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let user = value?["user"] as? String ?? ""
                if user == Auth.auth().currentUser!.uid {
                    rest.ref.removeValue()
                }
            }
        })
    }
    
    func updateUserData() {
        let uid = Auth.auth().currentUser!.uid
        self.ref.child("Users/\(uid)/username").setValue(self.account_name.text)
        self.ref.child("Users/\(uid)/fullname").setValue(self.full_name.text)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Account has been updated!"
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            self.setUserData(fullname: self.full_name.text!, usertype: usertype, username: self.account_name.text!, isUserLoggedIn: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateAccount(_ sender: Any) {
        var error = ""
        if account_name.textColor == UIColor.black && account_name.text!.isEmpty {
            error += "Write a username\n"
        }
        if account_name.text!.contains(" ") {
            error += "Username can not contain spaces\n"
        }
        if full_name.textColor == UIColor.black && full_name.text!.isEmpty {
            error += "Write your full name\n"
        }
        if account_name.textColor == UIColor.black && !account_name.text!.isEmpty && account_name.text == username {
            error += "Username has not been changed\n"
        }
        if full_name.textColor == UIColor.black && !full_name.text!.isEmpty && full_name.text == fullname {
            error += "Full name has not been changed"
        }
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            var taken = false
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let user = value!["username"] as? String ?? ""
                if user == self.account_name.text! {
                    taken = true
                    self.showAlert(title: "Error", message: "Username is already taken")
                }
            }
            if error == "" && !self.account_name.text!.isEmpty && !taken {
                self.updateUserData()
            } else {
                self.showAlert(title: "Error", message: error)
            }
        })
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.gray {
            textField.text = ""
            textField.textColor = UIColor.black
        }
    }
}
