import UIKit
import FirebaseAuth
import Firebase

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var options = ["Account", "Edit profile", "Change password", "Delete account"]
    
    @IBOutlet weak var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
        settingsTable.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell) ?? CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        if (options[indexPath.row] == "Account") {
            cell.imageView!.image = UIImage(named: "Account.png")
            cell.separator.backgroundColor = .lightGray
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.textLabel!.textColor = .darkGray
            cell.textLabel!.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        }
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = options[indexPath.row]
        if (selectedRow == "Edit profile") {
            self.presentVC(segue: "EditProfileVC")
        } else if (selectedRow == "Change password") {
            changePassword()
        } else if (selectedRow == "Delete account") {
            deleteAccount()
        }
    }
    
    func removeUserPosts(path: String) {
        Database.database().reference().child(path).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let user = value?["user"] as? String ?? ""
                if user == uid {
                    rest.ref.removeValue()
                }
            }
        })
    }
    
    func deleteAccount(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want to delete your account?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.removeUserPosts(path: "Cases")
            self.removeUserPosts(path: "Discussions")
            self.removeUserPosts(path: "Researches")
            Auth.auth().currentUser!.delete { error in
                if error == nil {
                    self.showAlert(title: "Goodbye doctor", message: "We hope to see you again")
                    self.presentVC(segue: "LoginVC")
                } else {
                    self.showAlert(title: "Error", message: "There was an error deleting your account. Please try again")
                }
            }
        }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func changePassword() {
        let alert = UIAlertController(title: "Change password", message: "Enter new one", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let save = UIAlertAction(title: "Done", style: .default, handler: { alertAction -> Void in
            if let textField = alert.textFields?[0] {
                if textField.text!.count > 0 {
                    Auth.auth().currentUser!.updatePassword(to: textField.text!) { error in
                        var title = "Success!"
                        var message = "Password has been updated"
                        if error != nil {
                            title = "Error"
                            message = "Password can not be updated. Try again"
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
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
}
