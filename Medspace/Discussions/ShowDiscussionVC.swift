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
        initComponents()
        customNavBar()
    }
    
    func initComponents() {
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: discussion_description.bottomAnchor).isActive = true
        }
        user.text = "Posted by \(discussion!.user.username)"
        discussion_title.text = discussion!.title
        discussion_description.text = discussion!.description
        date.text = self.getFormattedDate(date: discussion!.date)
        speciality.text = discussion!.speciality.name.description
        speciality.backgroundColor = self.discussion!.speciality.color
        speciality.round(corners: .allCorners, cornerRadius: 10)
        speciality.textAlignment = .center
        if discussion!.user.id != uid {
            editButton.tintColor = UIColor.white
            deleteButton.tintColor =  UIColor.white
        }
        editButton.isEnabled = discussion!.user.id == uid
        deleteButton.isEnabled = discussion!.user.id == uid
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
            let path = "Discussions/\(uid!)/\(self.discussion!.id)"
            self.removeDataDB(path: path)
            self.removeDataDB(path: "Comments/\(path)")
            self.back()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showComments(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.discussion = discussion
        navigationController?.pushViewController(comments_vc!, animated: false)
    }
    
    @IBAction func goBack(_ sender: Any) {
        back()
    }
}
