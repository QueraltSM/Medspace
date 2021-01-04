import UIKit

class EditCommentVC: UIViewController {

    var comment: Comment?
    var commentPath: String!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var scrollview: UIScrollView!
    var news: News?
    var clinical_case: Case?
    var discussion: Discussion?
    var research: Research?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text = comment!.message
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        scrollview.backgroundColor = UIColor.white
    }
    
    @IBAction func saveComment(_ sender: Any) {
        var error = ""
        if message.text.isEmpty  {
            error = "Write a message"
        }
        if message.text == comment!.message {
            error = "You have not modified the previous data"
        }
        if error == "" {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to finally share this?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                let user = uid
                let now = self.comment!.date
                let path = "\(self.commentPath!)/\(now)::\(uid!)"
                self.postComment(path: path, message: self.message.text!, user: user!, date: now)
                let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
                comments_vc!.path = self.commentPath
                self.navigationController?.pushViewController(comments_vc!, animated: false)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error)
        }
    }
    
    @IBAction func backSegue(_ sender: Any) {
        let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        comments_vc!.commentPath = self.commentPath
        comments_vc!.news = self.news
        comments_vc!.clinical_case = self.clinical_case
        comments_vc!.discussion = self.discussion
        comments_vc!.research = self.research
        comments_vc!.path = self.commentPath
        self.navigationController?.pushViewController(comments_vc!, animated: false)
    }
}
