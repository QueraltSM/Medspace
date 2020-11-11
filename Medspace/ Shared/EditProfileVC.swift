import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditProfileVC: UIViewController  {

    @IBOutlet weak var fullnametxt: UITextField!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var changePassBtn: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernametxt.text = username
        fullnametxt.text = fullname
        ref = Database.database().reference()
    }
    
    func updateUser() {
        let uid = Auth.auth().currentUser!.uid
        self.ref.child("Users/\(uid)/username").setValue(self.usernametxt.text)
        self.ref.child("Users/\(uid)/fullname").setValue(self.fullnametxt.text)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Account has been updated!"
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            self.setUserData(fullname: self.fullnametxt.text!, usertype: usertype, username: self.usernametxt.text!, isUserLoggedIn: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkUsername(){
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            var taken = false
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let user = value!["username"] as? String ?? ""
                if user.lowercased() == self.usernametxt.text!.lowercased() {
                    taken = true
                    self.showAlert(title: "Error", message: "Username is already taken")
                }
            }
            if !taken {
                self.updateUser()
            }
        })
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        var error = ""
        if usernametxt.text! == username && fullnametxt.text! == fullname {
            error +=  "The data has not been changed since the last time"
        }
        if usernametxt.text!.isEmpty {
            error += "Username can not be empty\n"
        }
        if fullnametxt.text!.isEmpty {
            error += "Fullname can not be empty\n"
        }
        if usernametxt.text!.contains(" ") {
            error += "Username can not contain spaces"
        }
        if error == "" && usernametxt.text! == username {
            updateUser()
        } else if error == "" && usernametxt.text! != username {
            checkUsername()
        } else {
            showAlert(title:"Error", message: error)
        }
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
}
