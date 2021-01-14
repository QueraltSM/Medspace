import UIKit

class CreateCommentVC: UIViewController, UITextViewDelegate {

    var news: News?
    var clinical_case: Case?
    var discussion: Discussion?
    var research: Research?
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var scrollview: UIScrollView!
    var commentPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    func initComponents(){
        message.delegate = self
        message.textColor = UIColor.gray
        message.text = "Write a message"
        if #available(iOS 11.0, *) {
            scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
        } else {
            scrollview.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
        }
        scrollview.backgroundColor = UIColor.white
    }
    
    func askPost() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to share this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let now = Date().description
            let path = "\(self.commentPath!)/\(uid!)/\(now)"
            self.postComment(path: path, message: self.message.text!, user: uid!, date: now)
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePost(_ sender: Any) {
        if !validateTxtView(message) {
            showAlert(title: "Error", message: "Write a message")
        } else {
            askPost()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 200
    }
    
    func goBack() {
        let segue_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
        if news != nil {
            segue_vc!.news = news
        } else if clinical_case != nil {
            segue_vc!.clinical_case = clinical_case
        } else if discussion != nil {
            segue_vc!.discussion = discussion
        } else if research != nil {
            segue_vc!.research = research
        }
        navigationController?.pushViewController(segue_vc!, animated: false)
    }
}
