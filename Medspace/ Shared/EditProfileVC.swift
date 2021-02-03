import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditProfileVC: UIViewController, UITextViewDelegate, UITextFieldDelegate  {

    @IBOutlet weak var fullnametxt: UITextView!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var changePassBtn: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        usernametxt.delegate = self
        fullnametxt.delegate = self
        fullnametxt.text = fullname
        usernametxt.text = username
        usernametxt.textColor = UIColor.gray
        fullnametxt.textColor = UIColor.gray
        ref = Database.database().reference()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.gray {
            textField.text = ""
            textField.textColor = UIColor.black
        }
    }
    
    func storeUserData() {
        let uid = Auth.auth().currentUser!.uid
        self.ref.child("Users/\(uid)/username").setValue(self.usernametxt.text)
        self.ref.child("Users/\(uid)/fullname").setValue(self.fullnametxt.text)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Account has been updated!"
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {
            action in
            self.setUserData(fullname: self.fullnametxt.text!, usertype: usertype, username: self.usernametxt.text!, isUserLoggedIn: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func updateUser() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to update your account data?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.storeUserData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkUsername(){
        ref.child("Users").observeSingleEvent(of: .value, with: { snapshot in
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text!.count < 15
    }
    
    @IBAction func goSettings(_ sender: Any) {
        self.presentVC(segue: "SettingsVC")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        var error = ""
        if usernametxt.text! == username && fullnametxt.text! == fullname {
            error +=  "The data has not been changed since the last time"
        }
        if usernametxt.text!.contains(" ") {
            error += "Username can not contain spaces"
        }
        if usernametxt.text!.isEmpty || fullnametxt.text!.isEmpty {
            error = "Fill out all required fields\n"
        }
        if error == "" && usernametxt.text! == username {
            updateUser()
        } else if error == "" && usernametxt.text! != username {
            checkUsername()
        } else {
            showAlert(title:"Error", message: error)
        }
    }
}
