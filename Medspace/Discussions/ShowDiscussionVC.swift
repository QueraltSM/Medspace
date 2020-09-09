import UIKit
import FirebaseAuth
import FirebaseDatabase

class ShowDiscussionVC: UIViewController {

     var discussion: Discussion?
    @IBOutlet weak var discussion_description: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var discussion_title: UILabel!
    @IBOutlet weak var speciality: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false)
        discussion_title.text = discussion!.title
        discussion_description.text = discussion!.description
        date.text = discussion!.date
        speciality.text = discussion!.speciality.name.description
        speciality.backgroundColor = discussion!.speciality.color
        speciality.textColor = UIColor.white
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        
        if (discussion!.user.id == Auth.auth().currentUser!.uid) {
            setConfigDataToolbar()
        }
    }
    
    func setConfigDataToolbar() {
        self.navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deteleDiscussion)))
        items.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDiscussion)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.toolbarItems = items
    }
    
    @objc func editDiscussion() {
        let edit_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditDiscussionVC") as? EditDiscussionVC
        edit_discussion_vc!.discussion = self.discussion
        navigationController?.pushViewController(edit_discussion_vc!, animated: false)
    }
    
    @objc func deteleDiscussion(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.removeDataDB(path: "Discussions/\(self.discussion!.id)")
            self.presentVC(segue: "MyDiscussionsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
