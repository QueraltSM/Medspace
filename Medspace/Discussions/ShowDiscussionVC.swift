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
    @IBOutlet weak var user: UIButton!
    
    var user_author: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        user.setTitle("Posted by \(discussion!.user.username)", for: .normal)
        user.titleLabel!.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline).italic()
        discussion_title.text = discussion!.title
        discussion_description.text = discussion!.description
        date.text = discussion!.date
        speciality.text = discussion!.speciality.name.description
        speciality.backgroundColor = discussion!.speciality.color
        speciality.textColor = UIColor.black
        speciality.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if (user_author == nil && discussion!.user.id == uid) {
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
        let edit_discussion_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditDiscussionVC") as? EditDiscussionVC
        edit_discussion_vc!.discussion = self.discussion
        navigationController?.pushViewController(edit_discussion_vc!, animated: false)
    }
    
    @IBAction func deleteDiscussion(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Are you sure you want delete this?"
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
        alert.title = "Are you sure you want delete this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.removeDataDB(path: "Discussions/\(self.discussion!.id)")
            self.presentVC(segue: "MyDiscussionsVC")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.discussion = discussion
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
}
