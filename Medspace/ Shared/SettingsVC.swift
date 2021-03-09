import UIKit
import FirebaseAuth
import Firebase

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var options = ["", "Edit profile", "Change password", "Delete account"]
    var ref: DatabaseReference!
    @IBOutlet weak var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customNavBar()
    }
    
    func initComponents(){
        ref = Database.database().reference()
        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        self.settingsTable.tableFooterView = footerView
        self.settingsTable.backgroundColor = UIColor.white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell) ?? CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.textColor = .black
        cell.textLabel!.textAlignment = .center
        cell.textLabel!.font = UIFont(name: "Copperplate-Bold", size: 23)
        cell.textLabel!.text = options[indexPath.section]
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section) {
            case 1:
                self.presentVC(segue: "EditProfileVC")
                break
            case 2:
                changePassword()
                break
            case 3:
                deleteAccount()
                break
            default:
                break
        }
    }
    
    func removePosts(path: String) {
        self.ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
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
    
    func loopComments(path: String, ref: DatabaseReference, snapshot: DataSnapshot, userid: String) {
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject] ?? [:]
            for childDict in dict {
                let data = childDict.value as? [String : AnyObject] ?? [:]
                for childData in data {
                    if (childData.key == userid) {
                        self.removeDataDB(path: "\(path)/\(child.key)/\(childDict.key)/\(childData.key)")
                    }
                }
            }
        }
    }
    
    func removeComments(path: String, userid: String) {
        ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
            self.loopComments(path: path, ref: self.ref, snapshot: snapshot, userid: userid)
        })
    }
    
    func removeFiles(path: String){
        ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                self.removeDataStorage(path: "\(path)/\(child.key)")
            }
        })
    }
    
    func removeAll(userid: String){
        removeFiles(path: "News/\(userid)")
        removeFiles(path: "Researches/\(userid)")
        self.removePosts(path: "News/\(userid)")
        self.removePosts(path: "Cases/\(userid)")
        self.removePosts(path: "Discussions/\(userid)")
        self.removePosts(path: "Researches/\(userid)")
        self.removePosts(path: "Comments/News/\(userid)")
        self.removePosts(path: "Comments/Cases/\(userid)")
        self.removePosts(path: "Comments/Discussions/\(userid)")
        self.removePosts(path: "Comments/Researches/\(userid)")
        self.removeComments(path: "Comments/News", userid: userid)
        self.removeComments(path: "Comments/Cases", userid: userid)
        self.removeComments(path: "Comments/Discussions", userid: userid)
        self.removeComments(path: "Comments/Researches", userid: userid)
        self.removeDataDB(path: "Users/\(userid)")
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
    
    func deleteAccount(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want to delete your account?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let userid = uid!
            Auth.auth().currentUser!.delete { error in
                if error == nil {
                    self.removeAll(userid: userid)
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alert.title = "Goodbye"
                    alert.message = "We hope to see you again"
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                        action in
                        self.presentVC(segue: "LoginVC")
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.showAlert(title: "Error", message: "There was an error deleting your account")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changePassword() {
        let alert = UIAlertController(title: "Change password", message: "Enter a new one", preferredStyle: .alert)
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
                } else {
                    self.showAlert(title: "Error", message: "Password can not be empty")
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
    
    @IBAction func didTapMenu(_ sender: Any) {
        swipeMenu()
    }
}
