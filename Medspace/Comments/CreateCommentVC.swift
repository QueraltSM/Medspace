import UIKit

class CreateCommentVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var scrollview: UIScrollView!
    var commentPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.delegate = self
        message.textColor = UIColor.gray
        scrollview.contentLayoutGuide.bottomAnchor.constraint(equalTo: message.bottomAnchor).isActive = true
        scrollview.backgroundColor = UIColor.white
    }
    
    func askPost() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Do you want to finally share this?"
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let user = uid
            let now = Date().description
            let path = "\(self.commentPath!)/\(now)::\(uid!)"
            self.postComment(path: path, message: self.message.text!, user: user!, date: now)
            let comments_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC
            comments_vc!.path = self.commentPath
            self.navigationController?.pushViewController(comments_vc!, animated: false)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePost(_ sender: Any) {
        if message.text.isEmpty {
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
}
