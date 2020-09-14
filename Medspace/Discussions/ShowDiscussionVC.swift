import UIKit
import FirebaseAuth
import FirebaseDatabase

class ShowDiscussionVC: UIViewController {

    var discussion: Discussion?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var discussion_description: UILabel!
    @IBOutlet weak var discussion_title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var speciality: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var user: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setHeader(largeTitles: false, gray: false)
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        discussion_title.text = discussion!.title
        discussion_description.text = discussion!.description
        date.text = discussion!.date
        speciality.text = discussion!.speciality.name.description
        speciality.backgroundColor = discussion!.speciality.color
        speciality.textColor = UIColor.black
        user.text = "Posted by \(discussion!.user.username)"
        user.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline).italic()
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if (discussion!.user.id == Auth.auth().currentUser!.uid) {
            configDiscussion(enabled: true)
        }
    }
    
    func configDiscussion(enabled: Bool) {
        editButton.isEnabled = enabled
        deleteButton.isEnabled = enabled
        if enabled {
            editButton.title = "Edit"
            deleteButton.title = "Delete"
        }
    }
    
    @IBAction func editDiscussion(_ sender: Any) {
        let edit_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditDiscussionVC1") as? EditDiscussionVC1
        edit_discussion_vc!.discussion = self.discussion
        navigationController?.pushViewController(edit_discussion_vc!, animated: false)
    }
    
    @IBAction func deleteDiscussion(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete it?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let path = "Discussions/\(self.discussion!.id)"
            self.removeDataDB(path: path)
            self.presentVC(segue: "MyDiscussionsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    
    @IBAction func showComments(_ sender: Any) {
        print("show comments")
    }
}
