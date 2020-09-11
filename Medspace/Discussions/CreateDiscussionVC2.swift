
import UIKit
import FirebaseAuth

class CreateDiscussionVC2: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var discussion_description: UITextView!
    var title_discussion: String = ""
    var speciality: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(largeTitles: false)
        discussion_description.delegate = self
        discussion_description.customTextView(view_text:"Write a description of the discussion...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.customTextView(view_text:"",view_color:UIColor.black, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            discussion_description.customTextView(view_text:"Write a description of the discussion...",view_color:UIColor.gray, view_font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), view_scroll: true)
        }
    }
    
    
    @IBAction func askPost(_ sender: Any) {
        if (discussion_description.textColor == UIColor.gray || discussion_description.text.isEmpty) {
            showAlert(title: "Error", message: "Write a description")
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.title = "Do you want to post the discussion?"
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                action in
                let user = Auth.auth().currentUser?.uid
                let now = Date()
                let final_date = self.getFormattedDate(date: now.description)
                let path = "Discussions/\(now)::\(user!)"
                self.postDiscussion(path: path, title: self.title_discussion, description: self.discussion_description.text!, speciality: self.speciality, user: user!, date: final_date)
                self.presentVC(segue: "MyDiscussionsVC")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
