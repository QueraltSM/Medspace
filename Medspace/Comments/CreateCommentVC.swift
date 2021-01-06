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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if let scrollView = scrollview, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
                       let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
                       let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
                       scrollView.contentInset.bottom = keyboardOverlap
                       scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
                       
                       let duration = (durationValue as AnyObject).doubleValue
                       let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
                       UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                           self.view.layoutIfNeeded()
                       }, completion: nil)
                   }
        }
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
        if !validate(message) {
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
